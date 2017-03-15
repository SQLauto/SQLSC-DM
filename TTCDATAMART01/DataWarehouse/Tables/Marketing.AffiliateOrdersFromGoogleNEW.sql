CREATE TABLE [Marketing].[AffiliateOrdersFromGoogleNEW]
(
[OrderID] [int] NULL,
[PublisherID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PublisherName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount] [money] NULL,
[PublisherFee] [money] NULL,
[NetworkFee] [money] NULL,
[TotalFee] [money] NULL,
[Status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_AffiliateOrdersFromGoogleNEW] ON [Marketing].[AffiliateOrdersFromGoogleNEW] ([OrderID]) ON [PRIMARY]
GO
