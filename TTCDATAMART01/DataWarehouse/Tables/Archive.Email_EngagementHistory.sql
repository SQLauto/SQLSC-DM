CREATE TABLE [Archive].[Email_EngagementHistory]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfDate] [date] NOT NULL,
[gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsOfMonth] [tinyint] NOT NULL,
[AsOfYear] [smallint] NOT NULL,
[NewSeg] [tinyint] NOT NULL,
[Name] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[A12MF] [tinyint] NOT NULL,
[ActiveOrSwamp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LTDPurchasesBinID] [tinyint] NOT NULL,
[LTDAvgOrderBinID] [tinyint] NOT NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatAVPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatADPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3SubjectPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3OrderSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TenureDaysBinID] [tinyint] NOT NULL,
[LTDEMResponses] [int] NOT NULL,
[CustomerSegmentFnlID] [int] NULL,
[FlagMailable] [tinyint] NULL,
[COUNTRYCODE] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Back6Month_Emails_Sent] [int] NULL,
[Back6Month_engaged_Cnt] [int] NULL,
[Back6Month_click_Cnt] [int] NULL,
[Back6Month_Open_Cnt] [int] NULL,
[Back6Month_NumberOfOrders] [int] NULL,
[Back6Month_NumberOfEmailOrders] [int] NULL,
[Back6Month_NetOrderAmount] [money] NULL,
[Back6Month_NetOrderAmountEmail] [money] NULL,
[Back3Month_Emails_Sent] [int] NULL,
[Back3Month_engaged_Cnt] [int] NULL,
[Back3Month_click_Cnt] [int] NULL,
[Back3Month_Open_Cnt] [int] NULL,
[Back3Month_NumberOfOrders] [int] NULL,
[Back3Month_NumberOfEmailOrders] [int] NULL,
[Back3Month_NetOrderAmount] [money] NULL,
[Back3Month_NetOrderAmountEmail] [money] NULL,
[Forward1Month_Emails_Sent] [int] NULL,
[Forward1Month_engaged_Cnt] [int] NULL,
[Forward1Month_click_Cnt] [int] NULL,
[Forward1Month_Open_Cnt] [int] NULL,
[Forward1Month_NumberOfOrders] [int] NULL,
[Forward1Month_NumberOfEmailOrders] [int] NULL,
[Forward1Month_NetOrderAmount] [money] NULL,
[Forward1Month_NetOrderAmountEmail] [money] NULL,
[Back6Month_open_Flag] [bit] NULL,
[Back3Month_open_Flag] [bit] NULL,
[Forward1Month_open_Flag] [bit] NULL,
[Back6Month_click_Flag] [bit] NULL,
[Back3Month_click_Flag] [bit] NULL,
[Forward1Month_click_Flag] [bit] NULL,
[Back6Month_engaged_Flag] [bit] NULL,
[Back3Month_engaged_Flag] [bit] NULL,
[Forward1Month_engaged_Flag] [bit] NULL,
[Back6Month_ordered_Flag] [bit] NULL,
[Back3Month_ordered_Flag] [bit] NULL,
[Forward1Month_ordered_Flag] [bit] NULL,
[CustomerSegmentFnl] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDPurchasesBin] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgOrderBindesc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
