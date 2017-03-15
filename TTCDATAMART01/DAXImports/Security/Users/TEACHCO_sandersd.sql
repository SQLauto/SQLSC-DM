IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\sandersd')
CREATE LOGIN [TEACHCO\sandersd] FROM WINDOWS
GO
CREATE USER [TEACHCO\sandersd] FOR LOGIN [TEACHCO\sandersd]
GO
