IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\kanovkas')
CREATE LOGIN [TEACHCO\kanovkas] FROM WINDOWS
GO
CREATE USER [TEACHCO\kanovkas] FOR LOGIN [TEACHCO\kanovkas]
GO
