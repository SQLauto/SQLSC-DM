IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\ttcdomo')
CREATE LOGIN [TEACHCO\ttcdomo] FROM WINDOWS
GO
CREATE USER [TEACHCO\ttcdomo] FOR LOGIN [TEACHCO\ttcdomo]
GO
