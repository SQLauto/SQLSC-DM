IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\simpsonl')
CREATE LOGIN [TEACHCO\simpsonl] FROM WINDOWS
GO
CREATE USER [TEACHCO\simpsonl] FOR LOGIN [TEACHCO\simpsonl]
GO
