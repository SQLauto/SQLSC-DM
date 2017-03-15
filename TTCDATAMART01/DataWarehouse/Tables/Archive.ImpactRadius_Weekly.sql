CREATE TABLE [Archive].[ImpactRadius_Weekly]
(
[CampaignId] [int] NOT NULL,
[ActionTrackerId] [int] NOT NULL,
[OrderId] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerId] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Amount] [real] NULL,
[Quantity] [int] NOT NULL,
[EventDate] [varchar] (54) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsertedDate] [datetime] NULL CONSTRAINT [DF__ImpactRad__Inser__733D07D8] DEFAULT (getdate())
) ON [PRIMARY]
GO
