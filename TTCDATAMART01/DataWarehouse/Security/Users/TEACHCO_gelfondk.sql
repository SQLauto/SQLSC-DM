IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\gelfondk')
CREATE LOGIN [TEACHCO\gelfondk] FROM WINDOWS
GO
CREATE USER [TEACHCO\gelfondk] FOR LOGIN [TEACHCO\gelfondk]
GO
