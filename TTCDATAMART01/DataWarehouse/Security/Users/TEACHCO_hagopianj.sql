IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\hagopianj')
CREATE LOGIN [TEACHCO\hagopianj] FROM WINDOWS
GO
CREATE USER [TEACHCO\hagopianj] FOR LOGIN [TEACHCO\hagopianj]
GO
