-- BAI 3 TAO SQL LOGIN CHI DUOC INSERT/SELECT LICH SU
-- Mat khau lab: LabUser@2026 chi dung tren may ca nhan; neu doi thi go dung mat khau moi tren form ket noi.
-- SQL Server phai bat SQL Server and Windows Authentication mode (Mixed mode).
USE master;
GO
IF SUSER_ID(N'lab3_user') IS NULL
BEGIN
    CREATE LOGIN lab3_user WITH PASSWORD = 'LabUser@2026', CHECK_POLICY = ON;
END;
GO
USE LAB3_MaHoaKhoaCongKhai;
GO
IF DATABASE_PRINCIPAL_ID(N'lab3_user') IS NULL
BEGIN
    CREATE USER lab3_user FOR LOGIN lab3_user;
END;
GO
GRANT SELECT, INSERT ON OBJECT::dbo.History TO lab3_user;
GO