CREATE TABLE [Staging].[tgc_upsell_RECC_AM_SEG]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gender] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaFormatPreference] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourcePreference] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnlPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmail] [int] NULL,
[FlagMail] [int] NULL,
[age] [int] NULL,
[RecencyMonths] [int] NULL,
[TenureMonths] [int] NULL,
[Seg12mOrders] [int] NULL,
[Seg12mSales] [money] NULL,
[Seg12mEmailOrderRatio] [numeric] (24, 12) NULL,
[Seg60mOrders] [int] NULL,
[Seg60mSales] [money] NULL,
[Seg60mEmailOrderRatio] [numeric] (24, 12) NULL,
[ClickRatio] [numeric] (24, 12) NULL,
[TTB] [numeric] (24, 12) NULL,
[Segment] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMlastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
