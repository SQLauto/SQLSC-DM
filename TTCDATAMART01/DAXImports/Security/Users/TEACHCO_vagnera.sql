IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\vagnera')
CREATE LOGIN [TEACHCO\vagnera] FROM WINDOWS
GO
CREATE USER [TEACHCO\vagnera] FOR LOGIN [TEACHCO\vagnera]
GO
