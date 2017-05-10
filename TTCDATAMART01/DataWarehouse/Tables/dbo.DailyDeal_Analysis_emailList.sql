CREATE TABLE [dbo].[DailyDeal_Analysis_emailList]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Adcode] [int] NULL,
[StartDate] [datetime] NULL,
[FlagHoldOut] [int] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastPurchOrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BinDaysSinceLastPurchase] [int] NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxCourses] [int] NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
