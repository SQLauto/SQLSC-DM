IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\korfontak')
CREATE LOGIN [TEACHCO\korfontak] FROM WINDOWS
GO
CREATE USER [TEACHCO\korfontak] FOR LOGIN [TEACHCO\korfontak]
GO
