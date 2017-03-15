CREATE TABLE [Marketing].[EPC_Report]
(
[EPC_Report_id] [int] NOT NULL IDENTITY(1, 1),
[AsOfDate] [date] NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[CountryCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subscribed] [int] NOT NULL,
[HardBounce] [int] NULL,
[Blacklist] [int] NULL,
[SoftBounce] [int] NULL,
[FlagEmailable] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewCourseAnnouncements] [int] NULL,
[FreeLecturesClipsandInterviews] [int] NULL,
[ExclusiveOffers] [int] NULL,
[EPCFrequency] [int] NULL,
[UniqueCustCount] [int] NULL,
[TotalEmails] [int] NULL,
[ValidEmail] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__EPC_Repor__DMLas__5F079183] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[EPC_Report] ADD CONSTRAINT [PK__EPC_Repo__6F88E1A52AEE9AD4] PRIMARY KEY CLUSTERED  ([EPC_Report_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EPC_Report_ASofdate] ON [Marketing].[EPC_Report] ([AsOfDate]) ON [PRIMARY]
GO
