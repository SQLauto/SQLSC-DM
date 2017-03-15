CREATE TABLE [Marketing].[DMCustomerStatic_EmailContacts]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NULL,
[FlagHoldout] [int] NULL,
[IntlPurchaseDate] [datetime] NOT NULL,
[Adcode] [int] NULL,
[DownStreamDays] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_DMCustomerStatic_EmailContacts1] ON [Marketing].[DMCustomerStatic_EmailContacts] ([CustomerID]) ON [PRIMARY]
GO
