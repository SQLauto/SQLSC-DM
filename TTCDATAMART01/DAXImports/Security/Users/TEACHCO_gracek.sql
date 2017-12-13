IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\gracek')
CREATE LOGIN [TEACHCO\gracek] FROM WINDOWS
GO
