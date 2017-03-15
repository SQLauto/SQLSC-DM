IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\burnettp')
CREATE LOGIN [TEACHCO\burnettp] FROM WINDOWS
GO
CREATE USER [TEACHCO\burnettp] FOR LOGIN [TEACHCO\burnettp]
GO
