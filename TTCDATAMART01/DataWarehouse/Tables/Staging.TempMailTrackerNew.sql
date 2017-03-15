CREATE TABLE [Staging].[TempMailTrackerNew]
(
[adcode] [int] NULL,
[comboid] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjRank] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagMailed] [int] NULL,
[DMCustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetOrderAmount] [money] NULL,
[TotalCourseSales] [money] NULL,
[TotalCourseParts] [money] NULL,
[TotalCourseUnits] [int] NULL,
[MailHistCustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagHoldOut] [smallint] NULL,
[startdate] [datetime] NULL
) ON [PRIMARY]
GO
