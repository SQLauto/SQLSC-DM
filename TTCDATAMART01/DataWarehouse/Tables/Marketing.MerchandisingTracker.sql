CREATE TABLE [Marketing].[MerchandisingTracker]
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
[BillingState] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipCountryCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipState] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_RLS_YR] [int] NULL,
[CRS_RLS_MO] [int] NULL,
[customer_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenureBin] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VideoDL_ReleaseDate] [datetime] NULL,
[FormatMedia] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPR_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VDL_RLS_Flag] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagVideoDL] [tinyint] NULL,
[Ord_Source] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormatAVCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FrequencyPrior] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment2Prior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnlPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL,
[TotalParts] [dbo].[udtCourseParts] NULL,
[Sales] [money] NULL,
[ReportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
