-- =============================================
-- Proje Yönetim Sistemi - Stored Procedure'ler
-- =============================================
-- Bu script, yaygýn iþlemler için yeniden
-- kullanýlabilir prosedürler tanýmlar.
-- =============================================

USE ProjectManagementDB2;
GO

-- =============================================
-- Prosedür: Yeni Görev Ekleme
-- =============================================
-- Yeni görev oluþturur ve duplicate kontrolü yapar.
-- Otomatik olarak ilk durum kaydýný ekler.
-- =============================================
CREATE OR ALTER PROCEDURE sp_AddTask
    @project_id INT,
    @employee_id INT,
    @task_title NVARCHAR(150),
    @task_description NVARCHAR(255),
    @priority NVARCHAR(20),
    @start_date DATE,
    @due_date DATE,
    @assigned_role NVARCHAR(50),
    @assigned_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Duplicate görev kontrolü
    IF EXISTS (
        SELECT 1 FROM Tasks 
        WHERE task_title = @task_title
          AND employee_id = @employee_id
    )
    BEGIN
        RAISERROR('Bu çalýþan için ayný task zaten var!', 16, 1);
        RETURN;
    END

    -- Yeni görevi ekle
    INSERT INTO Tasks (project_id, employee_id, task_title, task_description, priority, status,
                       start_date, due_date, assigned_role, assigned_date)
    VALUES (
        @project_id, @employee_id, @task_title, @task_description, @priority,
        'Atandý', @start_date, @due_date, @assigned_role, @assigned_date
    );

    DECLARE @newTaskId INT = SCOPE_IDENTITY();

    -- Ýlk durum kaydýný oluþtur
    INSERT INTO TaskStatusHistory (task_id, old_status, new_status, changed_by)
    VALUES (@newTaskId, NULL, 'Atandý', @employee_id);

    -- Oluþturulan görev ID'sini döndür
    SELECT @newTaskId AS NewTaskID;
END
GO

-- =============================================
-- Prosedür: Görev Durumu Güncelleme
-- =============================================
-- Görev durumunu günceller ve geçmiþe kaydeder.
-- Ayný duruma güncellemeyi engeller.
-- =============================================
CREATE OR ALTER PROCEDURE sp_UpdateTaskStatus
    @task_id INT,
    @new_status NVARCHAR(50),
    @changed_by INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Görev var mý kontrolü
    IF NOT EXISTS (SELECT 1 FROM Tasks WHERE task_id = @task_id)
    BEGIN
        RAISERROR('Belirtilen Task bulunamadý!', 16, 1);
        RETURN;
    END

    -- Mevcut durumu al
    DECLARE @old_status NVARCHAR(50);
    SELECT @old_status = status FROM Tasks WHERE task_id = @task_id;

    -- Ayný duruma güncelleme kontrolü
    IF @old_status = @new_status
    BEGIN
        RAISERROR('Zaten bu statüde!', 16, 1);
        RETURN;
    END

    -- Durumu güncelle
    UPDATE Tasks
    SET status = @new_status
    WHERE task_id = @task_id;

    -- Manuel log kaydý (trigger'a ek olarak)
    INSERT INTO TaskStatusHistory (task_id, old_status, new_status, changed_by)
    VALUES (@task_id, @old_status, @new_status, @changed_by);

    -- Güncelleme bilgilerini döndür
    SELECT 
        @task_id AS TaskID,
        @old_status AS OldStatus,
        @new_status AS NewStatus,
        @changed_by AS ChangedBy,
        GETDATE() AS ChangedAt;
END
GO

-- =============================================
-- Prosedür: Çalýþaný Projeye Atama
-- =============================================
-- Çalýþaný projeye atar ve duplicate kontrolü yapar.
-- =============================================
CREATE OR ALTER PROCEDURE sp_AssignEmployeeToProject
    @project_id INT,
    @employee_id INT,
    @role_in_project NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Duplicate atama kontrolü
    IF EXISTS (
        SELECT 1 FROM ProjectMembers
        WHERE project_id = @project_id
          AND employee_id = @employee_id
    )
    BEGIN
        RAISERROR('Bu çalýþan zaten bu projeye atanmýþ!', 16, 1);
        RETURN;
    END

    -- Proje atamasýný ekle
    INSERT INTO ProjectMembers (project_id, employee_id, role_in_project, assigned_date)
    VALUES (@project_id, @employee_id, @role_in_project, GETDATE());

    -- Oluþturulan atama ID'sini döndür
    DECLARE @NewAssignmentID INT = SCOPE_IDENTITY();
    SELECT @NewAssignmentID AS NewAssignmentID;
END
GO

-- =============================================
-- Prosedür: Projeye Ait Görevleri Listeleme
-- =============================================
-- Belirli bir projenin tüm görevlerini ve
-- atanan çalýþanlarý getirir.
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetProjectTasks
    @project_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        t.task_id,
        t.task_title,
        t.status,
        t.employee_id,
        (e.FirstName + ' ' + e.LastName) AS employee_name,
        t.start_date,
        t.due_date
    FROM Tasks t
    LEFT JOIN Employees e 
        ON t.employee_id = e.EmployeeID
    WHERE t.project_id = @project_id;
END
GO

-- =============================================
-- Prosedür: Çalýþan Görev Özeti
-- =============================================
-- Belirli bir çalýþanýn tüm görevlerini detaylý
-- þekilde listeler (gecikme ve kalan gün dahil).
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetEmployeeTaskSummary
    @employee_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        t.task_id,
        t.task_title,
        p.project_name,
        t.status,
        t.priority,
        t.start_date,
        t.due_date,

        -- Kalan gün hesabý
        DATEDIFF(DAY, GETDATE(), t.due_date) AS DaysLeft,

        -- Gecikme durumu
        CASE 
            WHEN t.due_date < GETDATE() AND t.status <> 'Tamamlandý' 
                THEN 'Evet'
            ELSE 'Hayýr'
        END AS IsOverdue

    FROM Tasks t
    INNER JOIN Projects p ON t.project_id = p.project_id
    WHERE t.employee_id = @employee_id
    ORDER BY t.due_date ASC;
END
GO