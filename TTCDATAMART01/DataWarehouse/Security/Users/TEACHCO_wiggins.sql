IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\wiggins')
CREATE LOGIN [TEACHCO\wiggins] FROM WINDOWS
GO
CREATE USER [TEACHCO\wiggins] FOR LOGIN [TEACHCO\wiggins]
GO
