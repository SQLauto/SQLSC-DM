IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\codad')
CREATE LOGIN [TEACHCO\codad] FROM WINDOWS
GO
