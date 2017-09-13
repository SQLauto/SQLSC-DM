CREATE TABLE [Marketing].[AudibleTrackerResults]
(
[UUID] [int] NOT NULL IDENTITY(1, 1),
[SubmitDateTime] [datetime] NOT NULL,
[SubmitDate] [date] NOT NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerID] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEDIATYPE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUDIBLE_BRANDAWARENESS_VALUE] [int] NULL,
[AUDIBLE_SUBSCRIBER_VALUE] [int] NULL,
[AUDIBLE_TGC_PURCHASE_VALUE] [int] NULL,
[AUDIBLE_COURSES] [int] NULL,
[AUDIBLE_BACKLOG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUDIBLE_BACKLOG_NUMBER] [int] NULL,
[AUDIBLE_SATISFACTION_VALUE] [int] NULL,
[GENSAT_VALUE] [int] NULL,
[Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackerName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackerDate] [date] NULL,
[TrackerYear] [int] NULL,
[TrackerQrtr] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackerQrtrYr] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last_Updated_Date] [datetime] NOT NULL CONSTRAINT [DF_TGCAudibleTracker_UpdateDate] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Marketing].[AudibleTrackerResults] ADD CONSTRAINT [PK_AudTrackUUID] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[AudibleTrackerResults] ADD CONSTRAINT [UC_tgc_AudibleTracker] UNIQUE NONCLUSTERED  ([SubmitDate], [EmailAddress]) ON [PRIMARY]
GO
