IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\xinf')
CREATE LOGIN [TEACHCO\xinf] FROM WINDOWS
GO
CREATE USER [TEACHCO\xinf] FOR LOGIN [TEACHCO\xinf]
GO