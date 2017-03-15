IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\phillipsk')
CREATE LOGIN [TEACHCO\phillipsk] FROM WINDOWS
GO
CREATE USER [TEACHCO\phillipsk] FOR LOGIN [TEACHCO\phillipsk]
GO
