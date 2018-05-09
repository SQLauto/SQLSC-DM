CREATE TABLE [Marketing].[MC_TGC_MailingContact]
(
[MC_TGC_MailingContact_id] [bigint] NOT NULL IDENTITY(1, 1),
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
[DMLastupdated] [datetime] NOT NULL CONSTRAINT [DF__MC_Mailin__DMLas__3B1ECF05] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[MC_TGC_MailingContact] ADD CONSTRAINT [PK__MC_Maili__03C231911D8F7928] PRIMARY KEY CLUSTERED  ([MC_TGC_MailingContact_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MC_TGC_MailingContact_Customerid] ON [Marketing].[MC_TGC_MailingContact] ([CustomerID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_MC_MailingContact] ON [Marketing].[MC_TGC_MailingContact] ([CustomerID], [MonthStartDate]) ON [PRIMARY]
GO
