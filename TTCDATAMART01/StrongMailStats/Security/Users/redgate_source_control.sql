IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'redgate_source_control')
CREATE LOGIN [redgate_source_control] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [redgate_source_control] FOR LOGIN [redgate_source_control]
GO
