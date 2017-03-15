IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\chouiniereb')
CREATE LOGIN [TEACHCO\chouiniereb] FROM WINDOWS
GO
CREATE USER [TEACHCO\chouiniereb] FOR LOGIN [TEACHCO\chouiniereb]
GO
