IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\nolanm')
CREATE LOGIN [TEACHCO\nolanm] FROM WINDOWS
GO
