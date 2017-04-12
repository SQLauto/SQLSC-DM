CREATE TABLE [Archive].[EmailCaptureReportByCoupons]
(
[coupon] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSCOUPONNUMBER] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CouponDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustType] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrencyCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailCounts] [int] NULL,
[Orders] [int] NULL,
[Sales] [money] NULL,
[DMlastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
