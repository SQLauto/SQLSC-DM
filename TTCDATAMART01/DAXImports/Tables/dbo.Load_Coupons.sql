CREATE TABLE [dbo].[Load_Coupons]
(
[jscouponid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSCOUPONDESC] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSFROMDATE] [datetime] NOT NULL,
[JSTODATE] [datetime] NOT NULL,
[JSCOUPONNUMBER] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CURRENCYCODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SpecialShipping] [int] NOT NULL,
[ShippingAmount] [money] NULL,
[PHSCHEDULENAME] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CouponMin] [numeric] (28, 12) NULL,
[CouponMax] [numeric] (28, 12) NULL,
[CouponValue] [numeric] (28, 12) NULL,
[CouponType] [int] NULL,
[Voided] [int] NULL,
[PercentOff] [float] NULL,
[BonusItemPercentOff] [float] NULL,
[ApplyToMultipleItems] [bit] NULL,
[ItemThreshold] [int] NULL
) ON [PRIMARY]
GO
