IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\automate')
CREATE LOGIN [TEACHCO\automate] FROM WINDOWS
GO
CREATE USER [TEACHCO\automate] FOR LOGIN [TEACHCO\automate]
GO
