CREATE TABLE [Mapping].[Affiliate_WebOrders]
(
[ActionDate] [datetime] NULL,
[ActionId] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OID] [varchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[ATId] [int] NULL
) ON [PRIMARY]
GO
