CREATE TABLE [Marketing].[NatGeo_CoBrand_Report20140606]
(
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[MarketingOwner] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingCountryCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderStatus] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrencyCode] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseType] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CourseID] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Format] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Units] [int] NULL,
[Sales] [money] NULL,
[MinDateOrdered] [datetime] NULL,
[MaxDateOrdered] [datetime] NULL,
[ReportDate] [date] NULL
) ON [PRIMARY]
GO
