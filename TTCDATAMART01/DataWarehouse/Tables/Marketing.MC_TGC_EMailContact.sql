CREATE TABLE [Marketing].[MC_TGC_EMailContact]
(
[MC_TGC_EMailContact_id] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MonthStartDate] [date] NULL,
[TotalEMails] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__MC_TGC_EM__DMLas__353BD87D] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[MC_TGC_EMailContact] ADD CONSTRAINT [PK__MC_TGC_E__045F9F87593CF683] PRIMARY KEY CLUSTERED  ([MC_TGC_EMailContact_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_MC_EMailContact] ON [Marketing].[MC_TGC_EMailContact] ([CustomerID], [MonthStartDate]) ON [PRIMARY]
GO
