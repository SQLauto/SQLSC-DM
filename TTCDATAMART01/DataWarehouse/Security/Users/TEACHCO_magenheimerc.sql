IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\magenheimerc')
CREATE LOGIN [TEACHCO\magenheimerc] FROM WINDOWS
GO
CREATE USER [TEACHCO\magenheimerc] FOR LOGIN [TEACHCO\magenheimerc]
GO
