CREATE TABLE [Archive].[MerchandisingTracker2005to2007]
(
[FlagAudioVideo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Courseid] [int] NULL,
[AbbrvCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Topic] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[YR_Rls] [int] NULL,
[OrderYear] [int] NULL,
[OrderMonth] [int] NULL,
[CountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_RLS_YR] [int] NULL,
[CRS_RLS_MO] [int] NULL,
[customer_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenureBin] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VideoDL_ReleaseDate] [datetime] NULL,
[FormatMedia] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VDL_RLS_Flag] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagVideoDL] [tinyint] NULL,
[Ord_Source] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NULL,
[TotalParts] [dbo].[udtCourseParts] NULL,
[Sales] [money] NULL
) ON [PRIMARY]
GO
