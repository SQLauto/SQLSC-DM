CREATE TABLE [dbo].[SoundTrack_Analysis_20131217]
(
[AsOfDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentNew] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatCategory] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prior3M_AudioSales] [money] NULL,
[Prior3M_AudioOrders] [int] NULL,
[Prior3M_VideoSales] [money] NULL,
[Prior3M_VideoOrders] [int] NULL,
[Post3M_STSales] [money] NULL,
[Post3M_STOrders] [int] NULL,
[Post3M_AudioSales] [money] NULL,
[Post3M_AudioOrders] [int] NULL,
[Post3M_VideoSales] [money] NULL,
[Post3M_VideoOrders] [int] NULL,
[Post3M_SoundTrackByr] [int] NULL
) ON [PRIMARY]
GO
