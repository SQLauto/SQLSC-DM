IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'linkserver')
CREATE LOGIN [linkserver] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [linkserver] FOR LOGIN [linkserver]
GO
