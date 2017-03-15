CREATE TABLE [Archive].[Email_Engagement_6monthsDetailed]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfDate] [date] NOT NULL,
[AsOfMonth] [tinyint] NOT NULL,
[AsOfYear] [smallint] NOT NULL,
[NewSeg] [tinyint] NOT NULL,
[Name] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[A12MF] [tinyint] NOT NULL,
[ActiveOrSwamp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LTDPurchasesBinID] [tinyint] NOT NULL,
[LTDAvgOrderBinID] [tinyint] NOT NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatAVPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatADPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3SubjectPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3OrderSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TenureDaysBinID] [tinyint] NOT NULL,
[LTDEMResponses] [int] NOT NULL,
[CustomerSegmentFnlID] [int] NULL,
[FlagMailable] [tinyint] NULL,
[Countrycode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailaddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[opens] [int] NULL,
[clicks] [int] NULL,
[email_cnt] [int] NULL
) ON [PRIMARY]
GO
