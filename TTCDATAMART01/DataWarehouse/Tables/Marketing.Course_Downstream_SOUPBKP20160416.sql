CREATE TABLE [Marketing].[Course_Downstream_SOUPBKP20160416]
(
[ReportDate] [datetime] NOT NULL,
[ordersource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SequenceNum] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MD_CountryID] [int] NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_AudienceID] [int] NULL,
[MD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelID] [int] NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignID] [int] NULL,
[MD_Campaign] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Year] [int] NULL,
[MD_PriceTypeID] [int] NULL,
[MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[AbbrvCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[CourseHours] [float] NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Topic] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubTopic] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreReleaseCoursePref] [float] NULL,
[PreReleaseSubjectMultiplier] [float] NULL,
[PrefPoint] [float] NULL,
[TGCPlus_SubjCat] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagAudioVideo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagCD] [tinyint] NULL,
[FlagDVD] [tinyint] NULL,
[FlagAudioDL] [tinyint] NULL,
[FlagVideoDL] [tinyint] NULL,
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
[ProfessorID] [int] NULL,
[Prof_FistName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prof_LastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfQual] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalSales_15Days] [money] NULL,
[TotalUnits_15Days] [int] NULL,
[TotalParts_15Days] [money] NULL,
[TotalOverallSales_15Days] [money] NULL,
[TotalOverallUnits_15Days] [int] NULL,
[TotalOverallParts_15Days] [money] NULL,
[TotalSales_1Mnth] [money] NULL,
[TotalUnits_1Mnth] [int] NULL,
[TotalParts_1Mnth] [money] NULL,
[TotalOverallSales_1Mnth] [money] NULL,
[TotalOverallUnits_1Mnth] [int] NULL,
[TotalOverallParts_1Mnth] [money] NULL,
[TotalSales_2Mnth] [money] NULL,
[TotalUnits_2Mnth] [int] NULL,
[TotalParts_2Mnth] [money] NULL,
[TotalOverallSales_2Mnth] [money] NULL,
[TotalOverallUnits_2Mnth] [int] NULL,
[TotalOverallParts_2Mnth] [money] NULL,
[TotalSales_12Mnth] [money] NULL,
[TotalUnits_12Mnth] [int] NULL,
[TotalParts_12Mnth] [money] NULL,
[TotalOverallSales_12Mnth] [money] NULL,
[TotalOverallUnits_12Mnth] [int] NULL,
[TotalOverallParts_12Mnth] [money] NULL,
[TotalSales_6Mnth] [money] NULL,
[TotalUnits_6Mnth] [int] NULL,
[TotalParts_6Mnth] [money] NULL,
[TotalOverallSales_6Mnth] [money] NULL,
[TotalOverallUnits_6Mnth] [int] NULL,
[TotalOverallParts_6Mnth] [money] NULL,
[TotalSales_3Mnth] [money] NULL,
[TotalUnits_3Mnth] [int] NULL,
[TotalParts_3Mnth] [money] NULL,
[TotalOverallSales_3Mnth] [money] NULL,
[TotalOverallUnits_3Mnth] [int] NULL,
[TotalOverallParts_3Mnth] [money] NULL,
[TotalSales_15Mnth] [money] NULL,
[TotalUnits_15Mnth] [int] NULL,
[TotalParts_15Mnth] [money] NULL,
[TotalOverallSales_15Mnth] [money] NULL,
[TotalOverallUnits_15Mnth] [int] NULL,
[TotalOverallParts_15Mnth] [money] NULL,
[TotalSales_18Mnth] [money] NULL,
[TotalUnits_18Mnth] [int] NULL,
[TotalParts_18Mnth] [money] NULL,
[TotalOverallSales_18Mnth] [money] NULL,
[TotalOverallUnits_18Mnth] [int] NULL,
[TotalOverallParts_18Mnth] [money] NULL,
[TotalSales_21Mnth] [money] NULL,
[TotalUnits_21Mnth] [int] NULL,
[TotalParts_21Mnth] [money] NULL,
[TotalOverallSales_21Mnth] [money] NULL,
[TotalOverallUnits_21Mnth] [int] NULL,
[TotalOverallParts_21Mnth] [money] NULL,
[TotalSales_24Mnth] [money] NULL,
[TotalUnits_24Mnth] [int] NULL,
[TotalParts_24Mnth] [money] NULL,
[TotalOverallSales_24Mnth] [money] NULL,
[TotalOverallUnits_24Mnth] [int] NULL,
[TotalOverallParts_24Mnth] [money] NULL,
[TotalSales_30Mnth] [money] NULL,
[TotalUnits_30Mnth] [int] NULL,
[TotalParts_30Mnth] [money] NULL,
[TotalOverallSales_30Mnth] [money] NULL,
[TotalOverallUnits_30Mnth] [int] NULL,
[TotalOverallParts_30Mnth] [money] NULL,
[TotalSales_36Mnth] [money] NULL,
[TotalUnits_36Mnth] [int] NULL,
[TotalParts_36Mnth] [money] NULL,
[TotalOverallSales_36Mnth] [money] NULL,
[TotalOverallUnits_36Mnth] [int] NULL,
[TotalOverallParts_36Mnth] [money] NULL,
[TotalSales_48Mnth] [money] NULL,
[TotalUnits_48Mnth] [int] NULL,
[TotalParts_48Mnth] [money] NULL,
[TotalOverallSales_48Mnth] [money] NULL,
[TotalOverallUnits_48Mnth] [int] NULL,
[TotalOverallParts_48Mnth] [money] NULL,
[TotalSales_60Mnth] [money] NULL,
[TotalUnits_60Mnth] [int] NULL,
[TotalParts_60Mnth] [money] NULL,
[TotalOverallSales_60Mnth] [money] NULL,
[TotalOverallUnits_60Mnth] [int] NULL,
[TotalOverallParts_60Mnth] [money] NULL,
[TotalSales_72Mnth] [money] NULL,
[TotalUnits_72Mnth] [int] NULL,
[TotalParts_72Mnth] [money] NULL,
[TotalOverallSales_72Mnth] [money] NULL,
[TotalOverallUnits_72Mnth] [int] NULL,
[TotalOverallParts_72Mnth] [money] NULL,
[TotalSales_84Mnth] [money] NULL,
[TotalUnits_84Mnth] [int] NULL,
[TotalParts_84Mnth] [money] NULL,
[TotalOverallSales_84Mnth] [money] NULL,
[TotalOverallUnits_84Mnth] [int] NULL,
[TotalOverallParts_84Mnth] [money] NULL,
[TotalSales_96Mnth] [money] NULL,
[TotalUnits_96Mnth] [int] NULL,
[TotalParts_96Mnth] [money] NULL,
[TotalOverallSales_96Mnth] [money] NULL,
[TotalOverallUnits_96Mnth] [int] NULL,
[TotalOverallParts_96Mnth] [money] NULL,
[TotalSales_108Mnth] [money] NULL,
[TotalUnits_108Mnth] [int] NULL,
[TotalParts_108Mnth] [money] NULL,
[TotalOverallSales_108Mnth] [money] NULL,
[TotalOverallUnits_108Mnth] [int] NULL,
[TotalOverallParts_108Mnth] [money] NULL,
[TotalSales_120Mnth] [money] NULL,
[TotalUnits_120Mnth] [int] NULL,
[TotalParts_120Mnth] [money] NULL,
[TotalOverallSales_120Mnth] [money] NULL,
[TotalOverallUnits_120Mnth] [int] NULL,
[TotalOverallParts_120Mnth] [money] NULL,
[FlagCmplt15days] [int] NULL,
[FlagCmplt1Mnth] [int] NULL,
[FlagCmplt2Mnth] [int] NULL,
[FlagCmplt3Mnth] [int] NULL,
[FlagCmplt6Mnth] [int] NULL,
[FlagCmplt12Mnth] [int] NULL,
[FlagCmplt15Mnth] [int] NULL,
[FlagCmplt18Mnth] [int] NULL,
[FlagCmplt21Mnth] [int] NULL,
[FlagCmplt24Mnth] [int] NULL,
[FlagCmplt30Mnth] [int] NULL,
[FlagCmplt36Mnth] [int] NULL,
[FlagCmplt48Mnth] [int] NULL,
[FlagCmplt60Mnth] [int] NULL,
[FlagCmplt72Mnth] [int] NULL,
[FlagCmplt84Mnth] [int] NULL,
[FlagCmplt96Mnth] [int] NULL,
[FlagCmplt108Mnth] [int] NULL,
[FlagCmplt120Mnth] [int] NULL,
[UpdateDate] [datetime] NULL
) ON [PRIMARY]
GO
