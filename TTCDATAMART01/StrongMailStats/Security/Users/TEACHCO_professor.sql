IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\professor')
CREATE LOGIN [TEACHCO\professor] FROM WINDOWS
GO
CREATE USER [TEACHCO\professor] FOR LOGIN [TEACHCO\professor]
GO
