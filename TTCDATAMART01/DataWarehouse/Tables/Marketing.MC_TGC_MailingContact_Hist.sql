CREATE TABLE [Marketing].[MC_TGC_MailingContact_Hist]
(
[MC_TGC_MailingContact_Hist_id] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MonthStartDate] [date] NULL,
[TotalCatalogs] [int] NULL,
[TotalCatalogReactivations] [int] NULL,
[TotalDeepInactives] [int] NULL,
[TotalMagalogs] [int] NULL,
[TotalMag7s] [int] NULL,
[TotalLetters] [int] NULL,
[TotalConvertalogs] [int] NULL,
[TotalOtherMailings] [int] NULL,
[TotalMailings] [int] NULL,
[DMLastupdated] [datetime] NOT NULL CONSTRAINT [DF__MC_TGC_Ma__DMLas__5445DD42] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[MC_TGC_MailingContact_Hist] ADD CONSTRAINT [PK__MC_TGC_M__185348B7FD151EED] PRIMARY KEY CLUSTERED  ([MC_TGC_MailingContact_Hist_id]) ON [PRIMARY]
GO
