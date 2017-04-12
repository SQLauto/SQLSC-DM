CREATE TABLE [Archive].[EmailCaptureReportByOrdersAllRegSource]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SequenceNum] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerType] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[registration_source_id] [int] NULL,
[RegistrationSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[created_date] [datetime] NULL,
[NetOrderAmount] [money] NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coupon] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSCOUPONNUMBER] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CouponDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NOT NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdCode] [int] NOT NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subscribed] [int] NULL,
[FlagEmailSignUP] [int] NOT NULL,
[DMlastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
