IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\dicksonc')
CREATE LOGIN [TEACHCO\dicksonc] FROM WINDOWS
GO
