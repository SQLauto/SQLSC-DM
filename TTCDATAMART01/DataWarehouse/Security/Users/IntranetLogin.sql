IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IntranetLogin')
CREATE LOGIN [IntranetLogin] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [IntranetLogin] FOR LOGIN [IntranetLogin]
GO
