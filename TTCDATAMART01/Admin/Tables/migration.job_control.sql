CREATE TABLE [migration].[job_control]
(
[job_id] [uniqueidentifier] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[enabled_primary] [tinyint] NOT NULL,
[enabled_secondary] [tinyint] NOT NULL CONSTRAINT [DF__job_contr__enabl__276EDEB3] DEFAULT ((0))
) ON [PRIMARY]
GO
