IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\aqela')
CREATE LOGIN [TEACHCO\aqela] FROM WINDOWS
GO
CREATE USER [TEACHCO\aqela] FOR LOGIN [TEACHCO\aqela]
GO
