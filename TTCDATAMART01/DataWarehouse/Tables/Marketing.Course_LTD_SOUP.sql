CREATE TABLE [Marketing].[Course_LTD_SOUP]
(
[ReportDate] [datetime] NOT NULL,
[ordersource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SequenceNum] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelID] [int] NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignID] [int] NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Year] [int] NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[AbbrvCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[CourseHours] [money] NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Topic] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubTopic] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagAudioVideo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagCD] [tinyint] NULL,
[FlagDVD] [tinyint] NULL,
[FlagAudioDL] [tinyint] NULL,
[FlagVideoDL] [tinyint] NULL,
[PreReleaseCoursePref] [float] NULL,
[PreReleaseSubjectMultiplier] [float] NULL,
[PrefPoint] [float] NULL,
[VDL_RLS_Flag] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReleaseYear] [int] NULL,
[ReleaseMonth] [int] NULL,
[ReleaseDate] [datetime] NULL,
[CatalogYear] [int] NULL,
[CatalogMonth] [int] NULL,
[DaysSinceRelease] [int] NULL,
[MonthsSinceRelease] [int] NULL,
[YearsSinceRelease] [int] NULL,
[FormatMedia] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[WeekOrdered] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalSales] [money] NULL,
[TotalUnits] [int] NULL,
[TotalParts] [dbo].[udtCourseParts] NULL
) ON [PRIMARY]
GO
