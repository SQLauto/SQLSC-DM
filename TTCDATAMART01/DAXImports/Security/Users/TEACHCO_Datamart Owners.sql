IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\Datamart Owners')
CREATE LOGIN [TEACHCO\Datamart Owners] FROM WINDOWS
GO
CREATE USER [TEACHCO\Datamart Owners] FOR LOGIN [TEACHCO\Datamart Owners]
GO
