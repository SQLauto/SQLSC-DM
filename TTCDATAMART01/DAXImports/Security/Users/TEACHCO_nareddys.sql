IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\nareddys')
CREATE LOGIN [TEACHCO\nareddys] FROM WINDOWS
GO
CREATE USER [TEACHCO\nareddys] FOR LOGIN [TEACHCO\nareddys]
GO
