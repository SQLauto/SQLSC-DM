CREATE TABLE [Marketing].[TGCPlus_ConsumptionFreeMonthChurn_ib]
(
[AsofDate] [date] NULL,
[CustomerID] [bigint] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCCustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlCampaignID] [int] NULL,
[IntlCampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlMD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_ChannelID] [int] NULL,
[IntlMD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_PromotionTypeID] [int] NULL,
[IntlMD_Year] [int] NULL,
[IntlSubDate] [date] NULL,
[IntlSubWeek] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubMonth] [int] NULL,
[IntlSubYear] [int] NULL,
[IntlSubPlanID] [bigint] NULL,
[IntlSubPlanName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubDate] [date] NULL,
[SubWeek] [date] NULL,
[SubMonth] [int] NULL,
[SubYear] [int] NULL,
[SubPlanID] [int] NULL,
[SubPlanName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustStatusFlag] [float] NULL,
[PaidFlag] [int] NULL,
[LTDPaidAmt] [float] NULL,
[LastPaidDate] [date] NULL,
[LastPaidWeek] [date] NULL,
[LastPaidMonth] [int] NULL,
[LastPaidYear] [int] NULL,
[LastPaidAmt] [float] NULL,
[DSDayCancelled] [int] NULL,
[DSMonthCancelled] [int] NULL,
[DSDayDeferred] [int] NULL,
[TGCCustFlag] [int] NULL,
[TGCCustSegmentFcst] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCCustSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxSeqNum] [bigint] NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Age] [int] NULL,
[AgeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegDate] [date] NULL,
[RegMonth] [int] NULL,
[RegYear] [int] NULL,
[IntlPaidAmt] [float] NULL,
[IntlPaidDate] [date] NULL,
[CustStatus] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlCourseID] [int] NULL,
[IntlLectureNumber] [int] NULL,
[IntlFilmType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlLectureRunTime] [int] NULL,
[IntlMaxVPOS] [int] NULL,
[IntlDateTimePlayed] [datetime] NULL,
[IntlDatePlayed] [date] NULL,
[IntlUserAgent] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Intlvid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlStreamedMins] [numeric] (12, 1) NULL,
[IntlPlatform] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlWeekPlayed] [int] NULL,
[IntlYearPlayed] [int] NULL,
[IntlCourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlLectureName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubjectCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlStreamedMinBin] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlPlay_MSIS] [int] NULL,
[IntlPlay_DSIS] [int] NULL,
[IntlPlay_DSISBin] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TenureDays] [int] NULL,
[TenureMonths] [int] NULL,
[LTDCoursesWatched] [int] NULL,
[LTDCourseWatchBin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDLecturesWatched] [int] NULL,
[LTDLectureWatchBin] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDNumDaysWatched] [int] NULL,
[LTDNumPings] [int] NULL,
[LTDNumPlatforms] [int] NULL,
[LTDNumPlays] [int] NULL,
[LTDNumSubjects] [int] NULL,
[LTDNumSubjectBin] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDStreamedMins] [numeric] (38, 1) NULL,
[LTDStreamedMinsBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDStreamedHrs] [numeric] (38, 6) NULL,
[DS0_IntlSubDate] [date] NULL,
[DS0_StopDate] [date] NULL,
[minstamp] [date] NULL,
[maxstamp] [date] NULL,
[DS0Mnth_NumCourses] [int] NULL,
[DS0Mnth_CourseWatchBin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS0Mnth_NumLectures] [int] NULL,
[DS0Mnth_LectureWatchBin] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS0Mnth_NumDaysWatched] [int] NULL,
[DS0Mnth_NumPlatform] [int] NULL,
[DS0Mnth_NumPlays] [int] NULL,
[DS0Mnth_NumSubjects] [int] NULL,
[DS0Mnth_NumSubjectBin] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS0Mnth_StreamedMins] [numeric] (38, 1) NULL,
[DS0Mnth_StreamedMinsBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
