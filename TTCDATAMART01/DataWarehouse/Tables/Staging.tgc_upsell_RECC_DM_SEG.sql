CREATE TABLE [Staging].[tgc_upsell_RECC_DM_SEG]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gender] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastSales] [money] NULL,
[LastUnits] [int] NULL,
[LTDOrders] [int] NULL,
[MediaFormatPreference] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourcePreference] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnlPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmail] [int] NULL,
[FlagMail] [int] NULL,
[ClickCnt] [int] NULL,
[age] [int] NULL,
[RecencyMonths] [int] NULL,
[Segment] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
