-- =============================================
-- Proje Yönetim Sistemi - Trigger Tanýmlamalarý
-- =============================================
-- Bu script, otomatik iþlemler için trigger'larý
-- oluþturur ve veritabaný iþ akýþlarýný yönetir.
-- =============================================

USE ProjectManagementDB2;
GO

-- =============================================
-- Trigger: Görev Durum Deðiþikliði Geçmiþi
-- =============================================
-- Görev durumu her deðiþtiðinde otomatik olarak
-- geçmiþ tablosuna kayýt atar.
-- =============================================
CREATE TRIGGER trg_TaskStatusHistory
ON Tasks
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Sadece durum deðiþikliði varsa kayýt oluþtur
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

-- =============================================
-- Trigger: Yaklaþan Deadline Bildirimi
-- =============================================
-- Görev bitiþ tarihi 3 gün içindeyse
-- otomatik bildirim oluþturur.
-- =============================================
CREATE TRIGGER trg_DeadlineApproaching
ON Tasks
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 3 gün içinde bitecek görevler için uyarý
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

-- =============================================
-- Trigger: Geciken Görev Bildirimi
-- =============================================
-- Bitiþ tarihi geçmiþ ve tamamlanmamýþ
-- görevler için uyarý oluþturur.
-- =============================================
CREATE TRIGGER trg_TaskOverdue
ON Tasks
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Gecikmiþ görevler için bildirim
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

-- =============================================
-- Trigger: Görev Tamamlanma Bildirimi
-- =============================================
-- Görev tamamlandýðýnda ilgili çalýþana
-- bildirim gönderir.
-- =============================================
CREATE TRIGGER trg_TaskCompleted
ON Tasks
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Tamamlanan görevler için kutlama bildirimi
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