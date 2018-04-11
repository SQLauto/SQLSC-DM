CREATE TABLE [Archive].[Email_DormantCustomer_Holdout_20180313]
(
[customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Emailaddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentnew] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Segment] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DMlastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
