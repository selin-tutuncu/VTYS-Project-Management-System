-- =============================================
-- Proje Yönetim Sistemi - Veritabaný Oluþturma
-- =============================================
-- Bu script, proje yönetim sistemi için gerekli
-- tüm tablolarý ve iliþkileri oluþturur.
-- =============================================

-- Veritabaný oluþturma ve kullanma
CREATE DATABASE ProjectManagementDB2;
GO
USE ProjectManagementDB2;
GO

-- =============================================
-- Departmanlar Tablosu
-- Þirket içindeki farklý departmanlarý tutar
-- =============================================
CREATE TABLE Departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- =============================================
-- Çalýþanlar Tablosu
-- Sistem kullanýcýlarýnýn temel bilgilerini içerir
-- =============================================
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    DepartmentID INT NOT NULL,
    HireDate DATE NOT NULL,
    
    FOREIGN KEY (DepartmentID) REFERENCES Departments(department_id)
);

-- =============================================
-- Projeler Tablosu
-- Þirket içinde yürütülen projelerin detaylarý
-- =============================================
CREATE TABLE Projects (
    project_id INT IDENTITY(1,1) PRIMARY KEY,
    project_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE,
    status NVARCHAR(50) DEFAULT 'Aktif'
);

-- =============================================
-- Proje Üyeleri Tablosu
-- Projelere atanan çalýþanlar ve rolleri
-- =============================================
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

-- =============================================
-- Görevler Tablosu
-- Proje kapsamýnda atanan görevlerin detaylarý
-- =============================================
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

-- =============================================
-- Görev Durum Geçmiþi Tablosu
-- Görevlerin durum deðiþikliklerini izler
-- =============================================
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

-- =============================================
-- Bildirimler Tablosu
-- Sistem bildirimleri ve uyarýlarý
-- =============================================
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