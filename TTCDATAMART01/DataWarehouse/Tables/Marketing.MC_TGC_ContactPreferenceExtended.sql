CREATE TABLE [Marketing].[MC_TGC_ContactPreferenceExtended]
(
[MC_TGC_ContactPreferenceExtended_id] [bigint] NOT NULL IDENTITY(1, 1),
[Asofdate] [date] NULL,
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DistinctEmailCounts] [int] NULL,
[NewCourseAnnouncements] [tinyint] NULL,
[FreeLecturesClipsandInterviews] [tinyint] NULL,
[ExclusiveOffers] [tinyint] NULL,
[Frequency] [tinyint] NULL,
[FlagValidEmail] [tinyint] NULL,
[FlagEmailable] [tinyint] NULL,
[FlagMailPref] [tinyint] NULL,
[FlagMail] [tinyint] NULL,
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__MC_TGC_Co__DMLas__1DE9CC91] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[MC_TGC_ContactPreferenceExtended] ADD CONSTRAINT [PK__MC_TGC_C__47357818581E7EB4] PRIMARY KEY CLUSTERED  ([MC_TGC_ContactPreferenceExtended_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UC_MC_TGC_ContactPreferenceExtended_Customerid_AsofDate] ON [Marketing].[MC_TGC_ContactPreferenceExtended] ([Asofdate], [Customerid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MC_TGC_ContactPreferenceExtended_Customerid] ON [Marketing].[MC_TGC_ContactPreferenceExtended] ([Customerid]) ON [PRIMARY]
GO
