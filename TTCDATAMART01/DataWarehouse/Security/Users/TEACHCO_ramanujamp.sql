IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\ramanujamp')
CREATE LOGIN [TEACHCO\ramanujamp] FROM WINDOWS
GO
CREATE USER [TEACHCO\ramanujamp] FOR LOGIN [TEACHCO\ramanujamp]
GO
