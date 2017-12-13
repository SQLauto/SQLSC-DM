IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\yangh')
CREATE LOGIN [TEACHCO\yangh] FROM WINDOWS
GO
