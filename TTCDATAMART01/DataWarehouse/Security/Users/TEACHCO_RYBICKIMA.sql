IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\RYBICKIMA')
CREATE LOGIN [TEACHCO\RYBICKIMA] FROM WINDOWS
GO
CREATE USER [TEACHCO\RYBICKIMA] FOR LOGIN [TEACHCO\RYBICKIMA]
GO
