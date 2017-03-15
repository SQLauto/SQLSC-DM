CREATE TABLE [Mapping].[Affiliate_WebOrders]
(
[ActionDate] [datetime] NULL,
[ActionId] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Revenue] [money] NULL,
[ActionCost] [money] NULL,
[PromoCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Media] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaId] [int] NULL,
[ActionTracker] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ATId] [int] NULL
) ON [PRIMARY]
GO
