CREATE TABLE [Staging].[TempCourse_LISTfor_SOUP_Updt]
(
[CourseID] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AbbrvCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[CourseHours] [money] NULL,
[ReleaseDate] [datetime] NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryID] [int] NULL,
[PCASubjectCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BundleFlag] [tinyint] NULL,
[PreReleaseCoursePref] [float] NULL,
[PostReleaseCourseSat] [float] NULL,
[CSATAsOfDate] [datetime] NULL,
[FlagActive] [tinyint] NULL,
[TerminationDate] [smalldatetime] NULL,
[PreReleaseSubjectMultiplier] [float] NULL,
[PrefPoint] [float] NULL,
[PDSubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalPaidImages] [int] NULL,
[CostPaidImages] [money] NULL,
[TotalFreeImages] [int] NULL,
[Topic] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubTopic] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagAudioVideo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagAudioDL] [tinyint] NULL,
[FlagVideoDL] [tinyint] NULL,
[VideoDL_ReleaseDate] [datetime] NULL,
[FlagCD] [tinyint] NULL,
[FlagDVD] [tinyint] NULL,
[FlagAudioDLOnly] [tinyint] NULL,
[FlagBuffetSet] [bit] NULL,
[FlagCLRCourse] [tinyint] NULL,
[DateCLRCourseAdded] [date] NULL,
[DateCLRCourseRemoved] [date] NULL,
[HowToFlag] [tinyint] NULL,
[NonCoreFlag] [tinyint] NULL,
[CoBrandPartnerID] [smallint] NULL,
[PrimaryWebCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryWebSubcategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseCost] [money] NULL,
[TGCPlus_SubjCat] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfessorID] [money] NULL,
[Prof_FistName] [int] NULL,
[Prof_LastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfQual] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
