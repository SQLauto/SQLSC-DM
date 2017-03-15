CREATE TABLE [Staging].[TempCatalogRequest]
(
[Week] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship Date] [date] NULL,
[Catalog] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coupon Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coupon Expiration Date] [date] NULL,
[Catalog Priority Code] [float] NULL
) ON [PRIMARY]
GO
