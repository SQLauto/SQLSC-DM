CREATE TABLE [Marketing].[TGCPlus_Consumption_FreeTrial]
(
[customerid] [bigint] NULL,
[EntitlementDays] [int] NULL,
[DS_Service_period_from] [datetime] NULL,
[DS_Service_period_to] [datetime] NULL,
[UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TSTAMP] [date] NULL,
[Vid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StreamedMins] [numeric] (12, 1) NULL,
[plays] [int] NULL,
[Platform] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxVPOS] [int] NULL,
[Max_VPOSMins] [numeric] (17, 6) NULL,
[CourseID] [bigint] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureNum] [bigint] NULL,
[LectureName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureRunMins] [numeric] (26, 6) NULL,
[StreamedMinsCapped] [numeric] (26, 6) NULL,
[FINALStreamedMins] [numeric] (26, 6) NULL,
[FlagCompletedLecture] [int] NULL,
[LectureCompletedPrcnt] [float] NULL,
[DMLastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
