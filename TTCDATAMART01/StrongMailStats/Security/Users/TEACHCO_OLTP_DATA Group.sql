IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\OLTP_DATA Group')
CREATE LOGIN [TEACHCO\OLTP_DATA Group] FROM WINDOWS
GO
CREATE USER [TEACHCO\OLTP_DATA Group] FOR LOGIN [TEACHCO\OLTP_DATA Group]
GO
