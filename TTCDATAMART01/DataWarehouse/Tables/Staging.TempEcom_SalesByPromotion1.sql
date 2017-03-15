CREATE TABLE [Staging].[TempEcom_SalesByPromotion1]
(
[customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SequenceNum] [int] NULL,
[NetOrderAmount] [money] NULL,
[orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateOrdered] [datetime] NULL,
[catalogcode] [int] NOT NULL,
[catalogname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adcode] [int] NOT NULL,
[adcodename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PromotionTypeID] [smallint] NULL,
[PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Year] [int] NULL,
[MD_CampaignID] [int] NULL,
[MD_CampaignDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelID] [int] NULL,
[MD_ChannelDesc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customersince] [datetime] NULL,
[CustomerType] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WeekOf] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
