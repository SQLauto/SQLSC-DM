IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'strongmaildbload')
CREATE LOGIN [strongmaildbload] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [strongmaildbload] FOR LOGIN [strongmaildbload]
GO
