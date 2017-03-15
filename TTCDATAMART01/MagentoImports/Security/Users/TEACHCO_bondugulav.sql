IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\bondugulav')
CREATE LOGIN [TEACHCO\bondugulav] FROM WINDOWS
GO
CREATE USER [TEACHCO\bondugulav] FOR LOGIN [TEACHCO\bondugulav]
GO
