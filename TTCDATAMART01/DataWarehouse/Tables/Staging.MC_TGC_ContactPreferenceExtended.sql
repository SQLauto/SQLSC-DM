CREATE TABLE [Staging].[MC_TGC_ContactPreferenceExtended]
(
[AsofDate] [date] NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DistinctEmailCounts] [int] NOT NULL,
[NewCourseAnnouncements] [int] NOT NULL,
[FreeLecturesClipsandInterviews] [int] NOT NULL,
[ExclusiveOffers] [int] NOT NULL,
[Frequency] [int] NOT NULL,
[FlagValidEmail] [int] NOT NULL,
[FlagEmailable] [int] NOT NULL,
[FlagMail] [int] NOT NULL,
[FlagMailPref] [bit] NOT NULL
) ON [PRIMARY]
GO
