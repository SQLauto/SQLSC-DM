IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\smithr')
CREATE LOGIN [TEACHCO\smithr] FROM WINDOWS
GO
CREATE USER [TEACHCO\smithr] FOR LOGIN [TEACHCO\smithr]
GO
