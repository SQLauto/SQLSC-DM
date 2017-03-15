CREATE TABLE [Archive].[TGCPlus_CustomerSignature20160701]
(
[AsofDate] [date] NULL,
[CustomerID] [bigint] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCCustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlCampaignID] [int] NULL,
[IntlCampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlMD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_ChannelID] [int] NULL,
[IntlMD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_PromotionTypeID] [int] NULL,
[IntlMD_Year] [int] NULL,
[IntlSubDate] [date] NULL,
[IntlSubWeek] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubMonth] [int] NULL,
[IntlSubYear] [int] NULL,
[IntlSubPlanID] [bigint] NULL,
[IntlSubPlanName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[TGCCustFlag] [int] NULL,
[TGCCustSegmentFcst] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCCustSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxSeqNum] [bigint] NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Age] [int] NULL,
[AgeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
