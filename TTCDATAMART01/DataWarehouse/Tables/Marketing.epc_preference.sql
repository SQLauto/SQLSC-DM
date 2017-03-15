CREATE TABLE [Marketing].[epc_preference]
(
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[snooze_start_date] [datetime] NULL,
[snooze_end_date] [datetime] NULL,
[Snoozed] [int] NULL,
[NewCourseAnnouncements] [int] NULL,
[FreeLecturesClipsandInterviews] [int] NULL,
[ExclusiveOffers] [int] NULL,
[Frequency] [int] NULL,
[Subscribed] [int] NULL,
[HardBounce] [int] NULL,
[Blacklist] [int] NULL,
[SoftBounce] [int] NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MagentoDaxMapped_Flag] [int] NULL,
[ChildCustomerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Child_Flag] [int] NULL,
[Reinstated] [bit] NULL CONSTRAINT [DF__epc_prefe__Reins__1F4E323B] DEFAULT ((0)),
[Lastupdated] [datetime] NULL CONSTRAINT [DF__epc_prefe__Lastu__20425674] DEFAULT (getdate())
) ON [PRIMARY]
GO
