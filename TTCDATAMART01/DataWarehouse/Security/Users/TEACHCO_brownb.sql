IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\brownb')
CREATE LOGIN [TEACHCO\brownb] FROM WINDOWS
GO
CREATE USER [TEACHCO\brownb] FOR LOGIN [TEACHCO\brownb]
GO
