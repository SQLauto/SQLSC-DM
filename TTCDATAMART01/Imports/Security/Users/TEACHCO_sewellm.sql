IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\sewellm')
CREATE LOGIN [TEACHCO\sewellm] FROM WINDOWS
GO
CREATE USER [TEACHCO\sewellm] FOR LOGIN [TEACHCO\sewellm]
GO
