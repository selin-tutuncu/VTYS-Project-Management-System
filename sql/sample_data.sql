-- =============================================
-- Proje Yönetim Sistemi - Örnek Veri Ekleme
-- =============================================
-- Bu script, test ve geliþtirme amaçlý
-- örnek veriler ekler.
-- =============================================

USE ProjectManagementDB2;
GO

-- =============================================
-- Departman Verileri
-- =============================================
INSERT INTO Departments (department_name)
VALUES
('Bilgi Teknolojileri'),
('Ýnsan Kaynaklarý'),
('Muhasebe'),
('Pazarlama'),
('Satýþ'),
('Ar-Ge'),
('Operasyon'),
('Yazýlým Geliþtirme'),
('Veri Analitiði'),
('Proje Yönetimi'),
('Donaným Destek'),
('Kalite Güvence');

-- =============================================
-- Çalýþan Verileri
-- Farklý departmanlardan çalýþanlar
-- =============================================
INSERT INTO Employees (FirstName, LastName, Email, DepartmentID, HireDate)
VALUES
('Elif Seda', 'Demirhan', 'elif.demirhan@example.com', 1, '2022-03-01'),
('Selin', 'Tütüncü', 'selin.tutuncu@example.com', 2, '2023-01-15'),
('Sude Naz', 'Görmez', 'sudenaz.gormez@example.com', 3, '2024-05-22'),
('Merve', 'Pýnar', 'merve.pinar@example.com', 4, '2023-11-11'),
('John', 'Miller', 'john.miller@example.com', 5, '2021-09-10'),
('Emma', 'Wilson', 'emma.wilson@example.com', 1, '2020-02-12'),
('Oliver', 'Brown', 'oliver.brown@example.com', 2, '2022-07-19'),
('Sophia', 'Taylor', 'sophia.taylor@example.com', 6, '2023-02-01'),
('James', 'Anderson', 'james.anderson@example.com', 7, '2024-01-05'),
('Mia', 'Thompson', 'mia.thompson@example.com', 8, '2022-10-20'),
('Liam', 'Clark', 'liam.clark@example.com', 9, '2021-11-13'),
('Ava', 'White', 'ava.white@example.com', 10, '2024-03-18'),
('Noah', 'Hall', 'noah.hall@example.com', 3, '2023-07-07'),
('Isabella', 'Harris', 'isabella.harris@example.com', 4, '2020-08-08'),
('Lucas', 'Lewis', 'lucas.lewis@example.com', 11, '2022-06-15'),
('Amelia', 'Young', 'amelia.young@example.com', 12, '2023-09-09'),
('Daniel', 'King', 'daniel.king@example.com', 5, '2024-02-27'),
('Charlotte', 'Scott', 'charlotte.scott@example.com', 2, '2022-12-12'),
('Benjamin', 'Green', 'benjamin.green@example.com', 1, '2023-03-25'),
('Harper', 'Adams', 'harper.adams@example.com', 6, '2021-04-04'),
('Henry', 'Baker', 'henry.baker@example.com', 9, '2022-01-01'),
('Evelyn', 'Nelson', 'evelyn.nelson@example.com', 7, '2024-05-05'),
('Alexander', 'Carter', 'alex.carter@example.com', 8, '2023-10-14'),
('Grace', 'Mitchell', 'grace.mitchell@example.com', 10, '2021-12-30'),
('Samuel', 'Perez', 'samuel.perez@example.com', 11, '2024-04-21');

-- =============================================
-- Proje Verileri
-- Aktif ve tamamlanmýþ projeler
-- =============================================
INSERT INTO Projects (project_name, description, start_date, end_date, status)
VALUES
('Kurumsal Web Sitesi Yenileme', 'Þirketin mevcut web sitesinin modern tasarýmla yenilenmesi', '2024-01-10', '2024-06-15', 'Aktif'),
('Mobil Uygulama Geliþtirme', 'Þirket için çok platformlu mobil uygulama geliþtirilmesi', '2024-03-01', NULL, 'Devam Ediyor'),
('CRM Sistem Entegrasyonu', 'CRM yazýlýmýnýn þirket süreçlerine entegrasyonu', '2023-09-15', '2024-02-28', 'Tamamlandý'),
('Pazarlama Otomasyon Sistemi', 'E-posta ve kampanya otomasyon yapýsýnýn kurulmasý', '2024-02-05', NULL, 'Aktif'),
('E-Ticaret Altyapý Geliþtirme', 'Yeni ürün satýþ platformunun backend + frontend geliþtirilmesi', '2024-05-12', NULL, 'Devam Ediyor'),
('Veri Ambarý Oluþturma', 'BI ve veri analizi süreçleri için veri ambarý kurulumu', '2023-11-20', NULL, 'Aktif'),
('Siber Güvenlik Testleri', 'Þirket sistemlerinde zafiyet taramasý ve güvenlik raporlamasý', '2024-04-04', NULL, 'Planlandý'),
('Personel Yönetim Sistemi', 'ÝK departmaný için personel yönetimi modülü geliþtirme', '2024-01-25', '2024-09-05', 'Tamamlandý'),
('Donaným Envanter Sistemi', 'Þirket donanýmlarýnýn takip edildiði sistem geliþtirme', '2024-06-01', NULL, 'Aktif'),
('Satýþ Performans Dashboard', 'Satýþ verilerinin analiz edildiði dashboard geliþtirilmesi', '2024-03-18', NULL, 'Devam Ediyor'),
('Proje 11', 'Açýklama', GETDATE(), NULL, 'Aktif'),
('Proje 12', 'Açýklama', GETDATE(), NULL, 'Aktif'),
('Proje 13', 'Açýklama', GETDATE(), NULL, 'Aktif'),
('Proje 14', 'Açýklama', GETDATE(), NULL, 'Aktif'),
('Proje 15', 'Açýklama', GETDATE(), NULL, 'Aktif');

-- =============================================
-- Proje Üyeleri Verileri
-- Projelere atanan çalýþanlar ve rolleri
-- =============================================
INSERT INTO ProjectMembers (project_id, employee_id, assigned_role, assigned_date)
VALUES
-- Proje 1 - Kurumsal Web Sitesi
(1, 1, 'Proje Yöneticisi', '2024-01-10'),
(1, 5, 'Geliþtirici', '2024-01-12'),
(1, 10, 'Analist', '2024-01-13'),

-- Proje 2 - Mobil Uygulama
(2, 2, 'ÝK Sorumlusu', '2024-02-01'),
(2, 8, 'Destek Uzmaný', '2024-02-02'),

-- Proje 3 - CRM Sistem
(3, 3, 'Muhasebe Uzmaný', '2024-03-05'),
(3, 14, 'Raporlama Analisti', '2024-03-07'),

-- Proje 4 - Pazarlama Otomasyon
(4, 4, 'Pazarlama Uzmaný', '2024-04-12'),
(4, 11, 'Veri Analisti', '2024-04-13'),

-- Proje 5 - E-Ticaret
(5, 6, 'Kýdemli Geliþtirici', '2024-05-20'),
(5, 7, 'Stajyer Geliþtirici', '2024-05-21'),
(5, 9, 'DevOps Uzmaný', '2024-05-22'),

-- Proje 6 - Veri Ambarý
(6, 12, 'Proje Koordinatörü', '2024-06-10'),
(6, 18, 'Takým Lideri', '2024-06-12'),

-- Proje 7 - Siber Güvenlik
(7, 13, 'Finans Analisti', '2024-07-01'),
(7, 17, 'Satýþ Temsilcisi', '2024-07-02'),

-- Proje 8 - Personel Yönetim
(8, 15, 'Donaným Uzmaný', '2024-08-15'),
(8, 16, 'Kalite Mühendisi', '2024-08-16'),

-- Proje 9 - Donaným Envanter
(9, 19, 'Veri Bilimci', '2024-09-01'),
(9, 20, 'Veri Analisti', '2024-09-02'),

-- Proje 10 - Satýþ Dashboard
(10, 21, 'Operasyon Uzmaný', '2024-10-05'),
(10, 22, 'Saha Sorumlusu', '2024-10-06'),

-- Proje 11-15
(11, 23, 'Backend Developer', '2024-11-01'),
(11, 24, 'Frontend Developer', '2024-11-02'),
(12, 25, 'Sistem Yöneticisi', '2024-12-10'),
(12, 1, 'Danýþman', '2024-12-11'),
(13, 7, 'AI Mühendisi', '2024-12-15'),
(13, 3, 'Veri Modelleyici', '2024-12-16'),
(14, 10, 'Araþtýrmacý', '2024-12-20'),
(14, 18, 'Test Uzmaný', '2024-12-21'),
(15, 5, 'Kýdemli Yazýlýmcý', '2024-12-25'),
(15, 14, 'Dokümantasyon Uzmaný', '2024-12-26');

-- =============================================
-- Görev Verileri
-- Projelere ait görevler ve atamalarý
-- =============================================
INSERT INTO Tasks 
(project_id, employee_id, task_title, task_description, priority, status, start_date, due_date, assigned_role, assigned_date)
VALUES
(1, 5, 'Frontend Arayüz Tasarýmý', 'Yeni web sitesi için ana sayfa tasarýmý', 'Yüksek', 'Atandý', '2024-01-15', '2024-01-25', 'Geliþtirici', '2024-01-15'),
(1, 10, 'Logo Güncelleme', 'Kurumsal logo modernize edilecek', 'Orta', 'Atandý', '2024-01-16', '2024-01-22', 'Tasarýmcý', '2024-01-16'),
(2, 2, 'Mobil API Baðlantýsý', 'Mobil uygulama için API endpoint entegrasyonu', 'Yüksek', 'Atandý', '2024-03-10', '2024-03-30', 'Geliþtirici', '2024-03-10'),
(2, 6, 'Push Notification Modülü', 'Uygulama içi bildirim sisteminin geliþtirilmesi', 'Orta', 'Devam Ediyor', '2024-03-12', '2024-03-28', 'Geliþtirici', '2024-03-12'),
(3, 14, 'Test Senaryosu Oluþturma', 'CRM entegrasyonu için test planý hazýrlanmasý', 'Düþük', 'Tamamlandý', '2023-12-10', '2024-01-05', 'Test Uzmaný', '2023-12-10'),
(4, 4, 'E-posta Þablon Tasarýmý', 'Kampanya mail þablonlarýnýn hazýrlanmasý', 'Orta', 'Atandý', '2024-02-10', '2024-02-20', 'Pazarlama Uzmaný', '2024-02-10'),
(4, 11, 'Otomasyon Modül Kodlama', 'Pazarlama otomasyon modülünün backend geliþtirmesi', 'Yüksek', 'Devam Ediyor', '2024-02-12', '2024-03-15', 'Geliþtirici', '2024-02-12'),
(5, 9, 'Ürün Katalog Yapýsý', 'E-ticaret ürün sayfasý veri modellemesi', 'Yüksek', 'Atandý', '2024-05-20', '2024-06-01', 'Geliþtirici', '2024-05-20'),
(5, 16, 'UX Revizyonu', 'Kullanýcý deneyimi iyileþtirme önerilerinin uygulanmasý', 'Orta', 'Atandý', '2024-05-22', '2024-06-05', 'UI/UX', '2024-05-22'),
(6, 1, 'Veri Ambarý Þema Tasarýmý', 'BI süreçleri için temel þema planlanmasý', 'Yüksek', 'Devam Ediyor', '2023-11-25', '2024-01-15', 'Veri Uzmaný', '2023-11-25'),
(6, 15, 'ETL Pipeline Hazýrlýðý', 'Veri ambarý için ETL süreçlerinin planlanmasý', 'Yüksek', 'Atandý', '2023-12-02', '2024-01-10', 'Analist', '2023-12-02'),
(7, 7, 'Zafiyet Taramasý', 'Sistem güvenlik taramalarýnýn yapýlmasý', 'Yüksek', 'Atandý', '2024-04-05', '2024-04-18', 'Siber Güvenlik Uzmaný', '2024-04-05'),
(7, 20, 'Penetrasyon Testi', 'Sisteme yönelik saldýrý simülasyonu', 'Yüksek', 'Atandý', '2024-04-08', '2024-04-22', 'Pentester', '2024-04-08'),
(8, 12, 'Kullanýcý Rolleri Modülü', 'Personel yönetim sistemine rol yetkilendirme', 'Orta', 'Atandý', '2024-01-28', '2024-02-10', 'Destek Uzmaný', '2024-01-28'),
(9, 18, 'Donaným Envanter Formu', 'Cihaz kayýt formunun geliþtirilmesi', 'Orta', 'Devam Ediyor', '2024-06-05', '2024-06-20', 'Donaným Uzmaný', '2024-06-05'),
(9, 25, 'Envanter API Entegrasyonu', 'Donaným envanter API baðlanacak', 'Yüksek', 'Atandý', '2024-06-07', '2024-06-18', 'Destek Mühendisi', '2024-06-07'),
(10, 3, 'Satýþ Dashboard KPI', 'KPI tanýmlarý çýkarýlacak', 'Orta', 'Atandý', '2024-03-19', '2024-04-05', 'Analist', '2024-03-19'),
(10, 8, 'Veri Temizleme', 'Dashboard için veri seti düzenlenecek', 'Düþük', 'Devam Ediyor', '2024-03-20', '2024-04-10', 'Veri Analisti', '2024-03-20'),
(10, 19, 'Grafik Modülü Geliþtirme', 'Dashboard grafik motoru kodlanacak', 'Yüksek', 'Atandý', '2024-03-22', '2024-04-15', 'Geliþtirici', '2024-03-22'),
(2, 24, 'Test Otomasyonu', 'Mobil uygulama için otomasyon senaryolarý yazýlacak', 'Orta', 'Atandý', '2024-03-14', '2024-03-28', 'Proje Asistaný', '2024-03-14');

-- =============================================
-- Görev Tarihlerini Gerçekçi Hale Getirme
-- Tamamlanan, devam eden ve yaklaþan görevler
-- =============================================
DECLARE @Today DATE = '2025-12-15';

-- Tamamlanan görevler (geçmiþ 10 gün içinde)
UPDATE Tasks
SET due_date = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 10, @Today)
WHERE status = 'Tamamlandý';

-- Devam eden görevler (15-30 gün sonra)
UPDATE Tasks
SET due_date = DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 16) + 15, @Today)
WHERE status = 'Devam Ediyor';

-- Atanmýþ görevler (5-20 gün sonra)
UPDATE Tasks
SET due_date = DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 16) + 5, @Today)
WHERE status = 'Atandý';

-- Yaklaþan deadline görevleri (2-7 gün sonra)
UPDATE Tasks
SET due_date = DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 6) + 2, @Today)
WHERE status = 'Atandý' AND task_id % 3 = 0;