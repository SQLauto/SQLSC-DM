CREATE TABLE [Marketing].[TGCPlus_CustomerUpsell]
(
[TGCCustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [bigint] NULL,
[SegmentGroup] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CourseID] [int] NULL,
[Rank] [float] NULL,
[Rank2] [bigint] NULL,
[UpdateDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
