CREATE TABLE [Marketing].[AJ_Non_SoundTrack]
(
[CourseID] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AbbrvCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [money] NULL,
[CourseHours] [money] NULL,
[ReleaseDate] [datetime] NULL,
[MediaTypeID] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [date] NULL,
[WeekOrdered] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalParts] [money] NULL,
[TotalQuantity] [int] NULL,
[TotalSales] [money] NULL
) ON [PRIMARY]
GO
