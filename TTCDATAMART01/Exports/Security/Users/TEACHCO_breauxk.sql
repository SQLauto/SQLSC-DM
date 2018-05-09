IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'TEACHCO\breauxk')
CREATE LOGIN [TEACHCO\breauxk] FROM WINDOWS
GO
CREATE USER [TEACHCO\breauxk] FOR LOGIN [TEACHCO\breauxk]
GO
