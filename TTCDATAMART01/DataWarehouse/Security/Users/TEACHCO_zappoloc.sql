IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\zappoloc')
CREATE LOGIN [TEACHCO\zappoloc] FROM WINDOWS
GO
CREATE USER [TEACHCO\zappoloc] FOR LOGIN [TEACHCO\zappoloc]
GO
