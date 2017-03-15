IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ebridge')
CREATE LOGIN [ebridge] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [ebridge] FOR LOGIN [ebridge]
GO
