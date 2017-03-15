CREATE TABLE [Staging].[TempMailTrackerAdcode]
(
[adcode] [int] NULL,
[comboid] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubjRank] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Decile] [int] NOT NULL,
[DemiDecile] [int] NOT NULL,
[FlagMailed] [int] NOT NULL,
[DMCustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetOrderAmount] [money] NULL,
[TotalCourseSales] [money] NULL,
[TotalCourseParts] [money] NULL,
[TotalCourseUnits] [int] NULL,
[MailHistCustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagHoldOut] [smallint] NULL,
[StartDate] [datetime] NULL
) ON [PRIMARY]
GO
