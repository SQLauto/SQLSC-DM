CREATE TABLE [dbo].[WebOrderDEL]
(
[SH_ConversionTime] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SH_WebOrderID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SH_OrderAmount] [money] NULL,
[SH_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SH_Publisher] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SH_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
