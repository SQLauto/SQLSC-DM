IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\curtisd')
CREATE LOGIN [TEACHCO\curtisd] FROM WINDOWS
GO
CREATE USER [TEACHCO\curtisd] FOR LOGIN [TEACHCO\curtisd] WITH DEFAULT_SCHEMA=[db_datareader]
GO
