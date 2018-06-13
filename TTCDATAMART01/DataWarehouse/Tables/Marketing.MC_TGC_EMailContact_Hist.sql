CREATE TABLE [Marketing].[MC_TGC_EMailContact_Hist]
(
[MC_TGC_EMailContact_Hist_id] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MonthStartDate] [date] NULL,
[TotalEMails] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__MC_TGC_EM__DMLas__4D98DFB3] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[MC_TGC_EMailContact_Hist] ADD CONSTRAINT [PK__MC_TGC_E__9D9FB46C6C0DC495] PRIMARY KEY CLUSTERED  ([MC_TGC_EMailContact_Hist_id]) ON [PRIMARY]
GO
