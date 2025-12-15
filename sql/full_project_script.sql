-- =============================================
-- PROJE YÖNETÝM SÝSTEMÝ - TAM KURULUM SCRÝPTÝ
-- =============================================
-- Bu script, veritabanýnýn tüm bileþenlerini
-- sýrayla oluþturur ve örnek veri ekler.
-- =============================================
-- Oluþturma Tarihi: Aralýk 2024
-- Kullaným: SQL Server 2016+
-- =============================================

USE master;
GO

-- Mevcut veritabanýný kaldýr (varsa)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ProjectManagementDB2')
BEGIN
    ALTER DATABASE ProjectManagementDB2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ProjectManagementDB2;
END
GO

-- =============================================
-- 1. VERÝTABANI OLUÞTURMA
-- =============================================
CREATE DATABASE ProjectManagementDB2;
GO
USE ProjectManagementDB2;
GO

PRINT 'Veritabaný oluþturuldu.';
GO

-- =============================================
-- 2. TABLO YAPILARI
-- =============================================

-- Departmanlar
CREATE TABLE Departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- Çalýþanlar
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    DepartmentID INT NOT NULL,
    HireDate DATE NOT NULL,
    
    FOREIGN KEY (DepartmentID) REFERENCES Departments(department_id)
);

-- Projeler
CREATE TABLE Projects (
    project_id INT IDENTITY(1,1) PRIMARY KEY,
    project_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE,
    status NVARCHAR(50) DEFAULT 'Aktif'
);

-- Proje Üyeleri
CREATE TABLE ProjectMembers (
    member_id INT IDENTITY(1,1) PRIMARY KEY,
    project_id INT NOT NULL,
    employee_id INT NOT NULL,
    role NVARCHAR(50),
    assigned_role NVARCHAR(50),
    assigned_date DATE,
    role_in_project NVARCHAR(100),
    
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(EmployeeID)
);

-- Görevler
CREATE TABLE Tasks (
    task_id INT IDENTITY(1,1) PRIMARY KEY,
    project_id INT NOT NULL,
    employee_id INT NOT NULL,
    task_title NVARCHAR(150) NOT NULL,
    task_description NVARCHAR(255),
    priority NVARCHAR(20) CHECK (priority IN ('Düþük', 'Orta', 'Yüksek')),
    status NVARCHAR(30) DEFAULT 'Atandý',
    start_date DATE NOT NULL,
    due_date DATE,
    assigned_role NVARCHAR(50),
    assigned_date DATE,
    
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(EmployeeID)
);

-- Görev Durum Geçmiþi
CREATE TABLE TaskStatusHistory (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    task_id INT NOT NULL,
    old_status NVARCHAR(30),
    new_status NVARCHAR(30),
    changed_at DATETIME DEFAULT GETDATE(),
    changed_by INT NOT NULL,
    
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES Employees(EmployeeID)
);

-- Bildirimler
CREATE TABLE Notifications (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    message NVARCHAR(255) NOT NULL,
    notification_type NVARCHAR(50) NOT NULL,
    is_read BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Employees(EmployeeID)
);

PRINT 'Tablolar oluþturuldu.';
GO

-- =============================================
-- 3. TRIGGER TANIMLARI
-- =============================================

-- Görev durum deðiþikliði geçmiþi
CREATE TRIGGER trg_TaskStatusHistory
ON Tasks
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO TaskStatusHistory (task_id, old_status, new_status, changed_by, changed_at)
    SELECT  
        i.task_id,
        d.status AS old_status,
        i.status AS new_status,
        i.employee_id AS changed_by,
        GETDATE()
    FROM inserted i
    INNER JOIN deleted d ON i.task_id = d.task_id
    WHERE i.status <> d.status;
END;
GO

-- Yaklaþan deadline bildirimi
CREATE TRIGGER trg_DeadlineApproaching
ON Tasks
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notifications (task_id, user_id, message, notification_type)
    SELECT 
        i.task_id,
        i.employee_id,
        CONCAT('Görev için deadline yaklaþýyor: ', i.task_title),
        'Deadline Yaklaþýyor'
    FROM inserted i
    WHERE i.due_date IS NOT NULL
      AND DATEDIFF(DAY, GETDATE(), i.due_date) = 3;
END;
GO

-- Geciken görev bildirimi
CREATE TRIGGER trg_TaskOverdue
ON Tasks
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notifications (task_id, user_id, message, notification_type)
    SELECT 
        i.task_id,
        i.employee_id,
        CONCAT('Görev gecikti: ', i.task_title),
        'Gecikme'
    FROM inserted i
    WHERE i.due_date < GETDATE()
      AND i.status <> 'Tamamlandý';
END;
GO

-- Görev tamamlanma bildirimi
CREATE TRIGGER trg_TaskCompleted
ON Tasks
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notifications(task_id, user_id, message, notification_type)
    SELECT 
        i.task_id,
        i.employee_id,
        CONCAT('Görev tamamlandý: ', i.task_title),
        'Görev Tamamlandý'
    FROM inserted i
    INNER JOIN deleted d ON i.task_id = d.task_id
    WHERE d.status <> 'Tamamlandý'
      AND i.status = 'Tamamlandý';
END;
GO

PRINT 'Trigger''lar oluþturuldu.';
GO

-- =============================================
-- 4. VIEW TANIMLARI
-- =============================================

-- Görev detay bilgileri
CREATE VIEW V_TaskDetails AS
SELECT 
    t.task_id, t.task_title, t.task_description, t.priority, t.status,
    t.start_date, t.due_date,
    e.EmployeeID, e.FirstName + ' ' + e.LastName AS EmployeeName, e.Email,
    p.project_id, p.project_name, p.status AS project_status
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id;
GO

-- Yaklaþan deadline'lar
CREATE VIEW V_UpcomingDeadlines AS
SELECT 
    t.task_id, t.task_title, t.status, t.due_date,
    e.FirstName + ' ' + e.LastName AS EmployeeName, p.project_name
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id
WHERE t.due_date IS NOT NULL
  AND t.status NOT IN ('Tamamlandý')
  AND t.due_date <= DATEADD(DAY, 3, GETDATE())
  AND t.due_date >= GETDATE();
GO

-- Tamamlanmýþ görevler
CREATE VIEW V_CompletedTasks AS
SELECT 
    t.task_id, t.task_title, t.due_date, t.start_date,
    e.FirstName + ' ' + e.LastName AS EmployeeName, p.project_name
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id
WHERE t.status = 'Tamamlandý';
GO

-- Proje üyeleri detaylarý
CREATE VIEW V_ProjectMembers AS
SELECT 
    pm.member_id, pm.role AS ProjectRole,
    p.project_id, p.project_name,
    e.EmployeeID, e.FirstName + ' ' + e.LastName AS EmployeeName,
    d.department_name
FROM ProjectMembers pm
INNER JOIN Projects p ON pm.project_id = p.project_id
INNER JOIN Employees e ON pm.employee_id = e.EmployeeID
INNER JOIN Departments d ON e.DepartmentID = d.department_id;
GO

-- Departman görev istatistikleri
CREATE VIEW V_DepartmentTaskCount AS
SELECT 
    d.department_name, COUNT(t.task_id) AS TotalTasks
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Departments d ON e.DepartmentID = d.department_id
GROUP BY d.department_name;
GO

PRINT 'View''lar oluþturuldu.';
GO

-- =============================================
-- 5. STORED PROCEDURE TANIMLARI
-- =============================================

-- Yeni görev ekleme
CREATE PROCEDURE sp_AddTask
    @project_id INT, @employee_id INT, @task_title NVARCHAR(150),
    @task_description NVARCHAR(255), @priority NVARCHAR(20),
    @start_date DATE, @due_date DATE, @assigned_role NVARCHAR(50),
    @assigned_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Tasks WHERE task_title = @task_title AND employee_id = @employee_id)
    BEGIN
        RAISERROR('Bu çalýþan için ayný task zaten var!', 16, 1);
        RETURN;
    END

    INSERT INTO Tasks (project_id, employee_id, task_title, task_description, priority, status,
                       start_date, due_date, assigned_role, assigned_date)
    VALUES (@project_id, @employee_id, @task_title, @task_description, @priority,
            'Atandý', @start_date, @due_date, @assigned_role, @assigned_date);

    DECLARE @newTaskId INT = SCOPE_IDENTITY();
    INSERT INTO TaskStatusHistory (task_id, old_status, new_status, changed_by)
    VALUES (@newTaskId, NULL, 'Atandý', @employee_id);

    SELECT @newTaskId AS NewTaskID;
END
GO

-- Görev durumu güncelleme
CREATE PROCEDURE sp_UpdateTaskStatus
    @task_id INT, @new_status NVARCHAR(50), @changed_by INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Tasks WHERE task_id = @task_id)
    BEGIN
        RAISERROR('Belirtilen Task bulunamadý!', 16, 1);
        RETURN;
    END

    DECLARE @old_status NVARCHAR(50);
    SELECT @old_status = status FROM Tasks WHERE task_id = @task_id;

    IF @old_status = @new_status
    BEGIN
        RAISERROR('Zaten bu statüde!', 16, 1);
        RETURN;
    END

    UPDATE Tasks SET status = @new_status WHERE task_id = @task_id;
    INSERT INTO TaskStatusHistory (task_id, old_status, new_status, changed_by)
    VALUES (@task_id, @old_status, @new_status, @changed_by);

    SELECT @task_id AS TaskID, @old_status AS OldStatus, @new_status AS NewStatus,
           @changed_by AS ChangedBy, GETDATE() AS ChangedAt;
END
GO

-- Çalýþaný projeye atama
CREATE PROCEDURE sp_AssignEmployeeToProject
    @project_id INT, @employee_id INT, @role_in_project NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM ProjectMembers WHERE project_id = @project_id AND employee_id = @employee_id)
    BEGIN
        RAISERROR('Bu çalýþan zaten bu projeye atanmýþ!', 16, 1);
        RETURN;
    END

    INSERT INTO ProjectMembers (project_id, employee_id, role_in_project, assigned_date)
    VALUES (@project_id, @employee_id, @role_in_project, GETDATE());

    SELECT SCOPE_IDENTITY() AS NewAssignmentID;
END
GO

-- Projeye ait görevleri listeleme
CREATE PROCEDURE sp_GetProjectTasks
    @project_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT t.task_id, t.task_title, t.status, t.employee_id,
           (e.FirstName + ' ' + e.LastName) AS employee_name,
           t.start_date, t.due_date
    FROM Tasks t
    LEFT JOIN Employees e ON t.employee_id = e.EmployeeID
    WHERE t.project_id = @project_id;
END
GO

-- Çalýþan görev özeti
CREATE PROCEDURE sp_GetEmployeeTaskSummary
    @employee_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT t.task_id, t.task_title, p.project_name, t.status, t.priority,
           t.start_date, t.due_date,
           DATEDIFF(DAY, GETDATE(), t.due_date) AS DaysLeft,
           CASE WHEN t.due_date < GETDATE() AND t.status <> 'Tamamlandý' 
                THEN 'Evet' ELSE 'Hayýr' END AS IsOverdue
    FROM Tasks t
    INNER JOIN Projects p ON t.project_id = p.project_id
    WHERE t.employee_id = @employee_id
    ORDER BY t.due_date ASC;
END
GO

PRINT 'Stored Procedure''lar oluþturuldu.';
GO

-- =============================================
-- 6. ÖRNEK VERÝ EKLEME
-- =============================================

-- Departmanlar
INSERT INTO Departments (department_name)
VALUES ('Bilgi Teknolojileri'), ('Ýnsan Kaynaklarý'), ('Muhasebe'), ('Pazarlama'),
       ('Satýþ'), ('Ar-Ge'), ('Operasyon'), ('Yazýlým Geliþtirme'),
       ('Veri Analitiði'), ('Proje Yönetimi'), ('Donaným Destek'), ('Kalite Güvence');

-- Çalýþanlar (Örnek veri seti)
INSERT INTO Employees (FirstName, LastName, Email, DepartmentID, HireDate)
VALUES 
('Elif Seda', 'Demirhan', 'elif.demirhan@example.com', 1, '2022-03-01'),
('Selin', 'Tütüncü', 'selin.tutuncu@example.com', 2, '2023-01-15'),
('Sude Naz', 'Görmez', 'sudenaz.gormez@example.com', 3, '2024-05-22'),
('Merve', 'Pýnar', 'merve.pinar@example.com', 4, '2023-11-11'),
('John', 'Miller', 'john.miller@example.com', 5, '2021-09-10');

-- Projeler
INSERT INTO Projects (project_name, description, start_date, status)
VALUES 
('Kurumsal Web Sitesi Yenileme', 'Web sitesinin modern tasarýmla yenilenmesi', '2024-01-10', 'Aktif'),
('Mobil Uygulama Geliþtirme', 'Çok platformlu mobil uygulama', '2024-03-01', 'Devam Ediyor'),
('CRM Sistem Entegrasyonu', 'CRM yazýlým entegrasyonu', '2023-09-15', 'Tamamlandý');

PRINT 'Örnek veriler eklendi.';
PRINT 'Kurulum tamamlandý!';
GO

-- =============================================
-- 7. TEST SORULARI
-- =============================================

-- View'larý test et
SELECT * FROM V_TaskDetails;
SELECT * FROM V_UpcomingDeadlines;
SELECT * FROM V_CompletedTasks;

PRINT 'Test sorgularý çalýþtýrýldý.';
GO