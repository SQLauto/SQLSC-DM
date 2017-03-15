CREATE TABLE [Staging].[MostRecent3Orders]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateOrdered] [datetime] NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderItemID] [int] NULL,
[CourseID] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parts] [dbo].[udtCourseParts] NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectPreferenceID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMedia] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAV] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAD] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
