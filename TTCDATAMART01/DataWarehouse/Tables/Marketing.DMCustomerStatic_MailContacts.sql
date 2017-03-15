CREATE TABLE [Marketing].[DMCustomerStatic_MailContacts]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [date] NULL,
[FlagHoldout] [smallint] NULL,
[IntlPurchaseDate] [datetime] NOT NULL,
[adcode] [int] NOT NULL,
[DownStreamDays] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_DMCustomerStatic_MailContacts1] ON [Marketing].[DMCustomerStatic_MailContacts] ([CustomerID]) ON [PRIMARY]
GO
