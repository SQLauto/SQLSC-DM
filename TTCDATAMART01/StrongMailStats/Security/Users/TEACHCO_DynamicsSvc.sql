IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\DynamicsSvc')
CREATE LOGIN [TEACHCO\DynamicsSvc] FROM WINDOWS
GO
CREATE USER [TEACHCO\DynamicsSvc] FOR LOGIN [TEACHCO\DynamicsSvc]
GO
