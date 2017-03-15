CREATE TABLE [dbo].[Web_OrderCurrency]
(
[OrderID] [int] NOT NULL,
[SiteID] [int] NOT NULL,
[CurrencyCode] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Web_OrderCurrency] ADD CONSTRAINT [PK_OrderCurrency] PRIMARY KEY CLUSTERED  ([OrderID]) ON [PRIMARY]
GO
