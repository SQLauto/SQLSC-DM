IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\solomona')
CREATE LOGIN [TEACHCO\solomona] FROM WINDOWS
GO
CREATE USER [TEACHCO\solomona] FOR LOGIN [TEACHCO\solomona]
GO
