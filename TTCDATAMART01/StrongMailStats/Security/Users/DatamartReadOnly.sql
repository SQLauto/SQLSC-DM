IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'DatamartReadOnly')
CREATE LOGIN [DatamartReadOnly] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [DatamartReadOnly] FOR LOGIN [DatamartReadOnly]
GO
