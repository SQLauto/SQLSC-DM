CREATE TABLE [Marketing].[TGCPlus_TGCCustomerSpending]
(
[AsofDate] [date] NULL,
[CustomerID] [bigint] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCCustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlCampaignID] [int] NULL,
[IntlCampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlMDChannel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubDate] [date] NULL,
[IntlSubWeek] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubMonth] [int] NULL,
[IntlSubYear] [int] NULL,
[IntlSubPlanID] [bigint] NULL,
[IntlSubPlanName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubDate] [date] NULL,
[SubWeek] [date] NULL,
[SubMonth] [int] NULL,
[SubYear] [int] NULL,
[SubPlanID] [int] NULL,
[SubPlanName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustStatusFlag] [float] NULL,
[PaidFlag] [int] NULL,
[LTDPaidAmt] [float] NULL,
[LastPaidDate] [date] NULL,
[LastPaidWeek] [date] NULL,
[LastPaidMonth] [int] NULL,
[LastPaidYear] [int] NULL,
[LastPaidAmt] [float] NULL,
[DSDayCancelled] [int] NULL,
[DSMonthCancelled] [int] NULL,
[DSDayDeferred] [int] NULL,
[TGCCust] [int] NULL,
[TGCCustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCFrequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCNewSeg] [int] NULL,
[TGCName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCA12fm] [int] NULL,
[TGCID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCCustomerSince] [datetime] NULL,
[TGCCustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCCustomerSegmentFrcst] [varchar] (57) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatDPPref] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCSegAsOfDate] [date] NULL,
[TGCP_TenureDays] [int] NULL,
[TGCP_TenureMonthsCmplt] [int] NULL,
[TGCP1MnthCmplt] [int] NOT NULL,
[TGCP2MnthCmplt] [int] NOT NULL,
[TGCP3MnthCmplt] [int] NOT NULL,
[DaysSinceTGCCust] [int] NULL,
[TGCID2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlOrderDate] [datetime] NULL,
[LTDSales] [money] NULL,
[LTDOrders] [int] NULL,
[Past1MoSales] [money] NULL,
[Past1MoOrders] [int] NULL,
[Past2MoSales] [money] NULL,
[Past2MoOrders] [int] NULL,
[Past3MoSales] [money] NULL,
[Past3MoOrders] [int] NULL,
[Past4MoSales] [money] NULL,
[Past4MoOrders] [int] NULL,
[Past5MoSales] [money] NULL,
[Past5MoOrders] [int] NULL,
[Past6MoSales] [money] NULL,
[Past6MoOrders] [int] NULL,
[Past7MoSales] [money] NULL,
[Past7MoOrders] [int] NULL,
[Past8MoSales] [money] NULL,
[Past8MoOrders] [int] NULL,
[Past9MoSales] [money] NULL,
[Past9MoOrders] [int] NULL,
[Past10MoSales] [money] NULL,
[Past10MoOrders] [int] NULL,
[Past11MoSales] [money] NULL,
[Past11MoOrders] [int] NULL,
[Past12MoSales] [money] NULL,
[Past12MoOrders] [int] NULL,
[Post1MoSales] [money] NULL,
[Post1MoOrders] [int] NULL,
[Post2MoSales] [money] NULL,
[Post2MoOrders] [int] NULL,
[Post3MoSales] [money] NULL,
[Post3MoOrders] [int] NULL,
[Post4MoSales] [money] NULL,
[Post4MoOrders] [int] NULL,
[Post5MoSales] [money] NULL,
[Post5MoOrders] [int] NULL,
[Post6MoSales] [money] NULL,
[Post6MoOrders] [int] NULL,
[Post7MoSales] [money] NULL,
[Post7MoOrders] [int] NULL,
[Post8MoSales] [money] NULL,
[Post8MoOrders] [int] NULL,
[Post9MoSales] [money] NULL,
[Post9MoOrders] [int] NULL,
[Post10MoSales] [money] NULL,
[Post10MoOrders] [int] NULL,
[Post11MoSales] [money] NULL,
[Post11MoOrders] [int] NULL,
[Post12MoSales] [money] NULL,
[Post12MoOrders] [int] NULL,
[PostSales] [money] NULL,
[PostOrders] [int] NULL
) ON [PRIMARY]
GO
