IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'Omniture')
CREATE LOGIN [Omniture] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [Omniture] FOR LOGIN [Omniture]
GO
