CREATE TABLE [Marketing].[Affiliate_WebOrderCompare]
(
[ReportDate] [date] NULL,
[ActionDate] [datetime] NULL,
[ActionId] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Revenue] [money] NULL,
[ActionCost] [money] NULL,
[PromoCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Media] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaId] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubID1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubID2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubID3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SharedID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActionTracker] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ATId] [int] NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orderdate] [datetime] NULL,
[Sales] [money] NULL,
[Campaign] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfferCode] [int] NULL,
[OfferName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelID] [int] NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignID] [int] NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderStatus] [int] NULL,
[OrderStatusValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
