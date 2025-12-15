-- =============================================
-- Proje Yönetim Sistemi - View Tanýmlamalarý
-- =============================================
-- Bu script, karmaþýk sorgularý basitleþtirmek
-- için view'lar oluþturur.
-- =============================================

USE ProjectManagementDB2;
GO

-- =============================================
-- View: Görev Detay Bilgileri
-- =============================================
-- Görevlerin tüm iliþkili bilgileriyle
-- birlikte görüntülenmesini saðlar.
-- =============================================
CREATE VIEW V_TaskDetails AS
SELECT 
    t.task_id,
    t.task_title,
    t.task_description,
    t.priority,
    t.status,
    t.start_date,
    t.due_date,
    
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    e.Email,
    
    p.project_id,
    p.project_name,
    p.status AS project_status
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id;
GO

-- =============================================
-- View: Yaklaþan Deadline'lar
-- =============================================
-- Önümüzdeki 3 gün içinde bitecek görevleri
-- listeler (raporlama ve izleme için).
-- =============================================
CREATE VIEW V_UpcomingDeadlines AS
SELECT 
    t.task_id,
    t.task_title,
    t.status,
    t.due_date,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    p.project_name
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id
WHERE 
    t.due_date IS NOT NULL
    AND t.status NOT IN ('Tamamlandý')
    AND t.due_date <= DATEADD(DAY, 3, GETDATE())
    AND t.due_date >= GETDATE();
GO

-- =============================================
-- View: Tamamlanmýþ Görevler
-- =============================================
-- Baþarýyla tamamlanmýþ görevlerin listesi
-- performans deðerlendirmeleri için kullanýlýr.
-- =============================================
CREATE VIEW V_CompletedTasks AS
SELECT 
    t.task_id,
    t.task_title,
    t.due_date,
    t.start_date,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    p.project_name
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id
WHERE t.status = 'Tamamlandý';
GO

-- =============================================
-- View: Proje Üyeleri Detaylarý
-- =============================================
-- Projelere atanan çalýþanlarý ve rollerini
-- departman bilgileriyle birlikte gösterir.
-- =============================================
CREATE VIEW V_ProjectMembers AS
SELECT 
    pm.member_id,
    pm.role AS ProjectRole,
    p.project_id,
    p.project_name,
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    d.department_name
FROM ProjectMembers pm
INNER JOIN Projects p ON pm.project_id = p.project_id
INNER JOIN Employees e ON pm.employee_id = e.EmployeeID
INNER JOIN Departments d ON e.DepartmentID = d.department_id;
GO

-- =============================================
-- View: Departman Görev Ýstatistikleri
-- =============================================
-- Her departmanýn toplam görev sayýsýný gösterir.
-- Kaynak planlama ve performans analizi için.
-- =============================================
CREATE VIEW V_DepartmentTaskCount AS
SELECT 
    d.department_name,
    COUNT(t.task_id) AS TotalTasks
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Departments d ON e.DepartmentID = d.department_id
GROUP BY d.department_name;
GO

-- =============================================
-- View (Eski): Kapsamlý Görev Detaylarý
-- =============================================
-- Alternatif görev görüntüleme - eski format
-- (Geriye dönük uyumluluk için korundu)
-- =============================================
CREATE VIEW vw_TaskFullDetails AS
SELECT 
    t.task_id,
    t.task_title,
    t.task_description,
    t.priority,
    t.status,
    t.start_date,
    t.due_date,
    p.project_id,
    p.project_name,
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeFullName,
    d.department_name,
    pm.assigned_role AS ProjectRole
FROM Tasks t
INNER JOIN Projects p ON t.project_id = p.project_id
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Departments d ON e.DepartmentID = d.department_id
LEFT JOIN ProjectMembers pm 
    ON pm.project_id = p.project_id AND pm.employee_id = e.EmployeeID;
GO

-- =============================================
-- View (Eski): Yaklaþan Deadline'lar
-- =============================================
-- Eski format - kalan gün hesaplamasý dahil
-- =============================================
CREATE VIEW vw_UpcomingDeadlines AS
SELECT 
    t.task_id,
    t.task_title,
    t.due_date,
    DATEDIFF(DAY, GETDATE(), t.due_date) AS DaysLeft,
    e.FirstName + ' ' + e.LastName AS AssignedEmployee,
    p.project_name
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id
WHERE t.due_date IS NOT NULL
  AND DATEDIFF(DAY, GETDATE(), t.due_date) BETWEEN 1 AND 3
  AND t.status <> 'Tamamlandý';
GO

-- =============================================
-- View (Eski): Tamamlanmýþ Görevler
-- =============================================
-- Eski format - ekstra detaylarla
-- =============================================
CREATE VIEW vw_CompletedTasks AS
SELECT 
    t.task_id,
    t.task_title,
    t.task_description,
    t.start_date,
    t.due_date,
    t.assigned_date,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    p.project_name
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id
WHERE t.status = 'Tamamlandý';
GO

-- =============================================
-- View (Eski): Proje Üyeleri Detaylarý
-- =============================================
-- Eski format - tüm rol sütunlarýyla
-- =============================================
CREATE VIEW vw_ProjectMembersDetails AS
SELECT 
    pm.project_id,
    p.project_name,
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeFullName,
    d.department_name,
    pm.role AS ProjectRole,
    pm.assigned_role,
    pm.assigned_date
FROM ProjectMembers pm
INNER JOIN Employees e ON pm.employee_id = e.EmployeeID
INNER JOIN Projects p ON pm.project_id = p.project_id
INNER JOIN Departments d ON e.DepartmentID = d.department_id;
GO

-- =============================================
-- View (Eski): Departman Görev Sayýsý
-- =============================================
-- Eski format - LEFT JOIN ile
-- =============================================
CREATE VIEW vw_DepartmentTaskCount AS
SELECT 
    d.department_name,
    COUNT(t.task_id) AS TotalTasks
FROM Departments d
LEFT JOIN Employees e ON d.department_id = e.DepartmentID
LEFT JOIN Tasks t ON e.EmployeeID = t.employee_id
GROUP BY d.department_name;
GO