CREATE TABLE [Staging].[TempNatGeoByFormatBKP20140407]
(
[DateOrdered] [datetime] NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdCode] [int] NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MarketingOwner] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingCountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrencyCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseType] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CourseID] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Format] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalQuantity] [int] NULL,
[TotalSales] [money] NULL,
[ReturnUnits] [int] NOT NULL,
[ReturnSales] [money] NOT NULL
) ON [PRIMARY]
GO
