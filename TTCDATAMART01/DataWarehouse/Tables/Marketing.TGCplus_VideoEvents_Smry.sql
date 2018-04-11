CREATE TABLE [Marketing].[TGCplus_VideoEvents_Smry]
(
[TGCplus_Consumption_Smry_ID] [bigint] NOT NULL IDENTITY(1, 1),
[UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [bigint] NOT NULL,
[TSTAMP] [date] NULL,
[Month] [int] NULL,
[Year] [int] NULL,
[Week] [int] NULL,
[Platform] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Player] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagAudio] [bit] NULL,
[FlagOffline] [bit] NULL,
[Speed] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[useragent] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[courseid] [int] NULL,
[episodeNumber] [int] NULL,
[FilmType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lectureRunTime] [int] NULL,
[CountryCode] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timezone] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plays] [int] NULL,
[pings] [int] NULL,
[MaxVPOS] [int] NULL,
[uip] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StreamedMins] [numeric] (12, 1) NULL,
[MinTstamp] [datetime] NULL,
[SeqNum] [int] NULL,
[Paid_SeqNum] [int] NULL,
[PaidFlag] [bit] NULL,
[DMLastUpdated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[TGCplus_VideoEvents_Smry] ADD CONSTRAINT [PK_TGCplus_Consumption_Smry_ID] PRIMARY KEY CLUSTERED  ([TGCplus_Consumption_Smry_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TGCplus_VideoEvents_Smry_TSTAMP] ON [Marketing].[TGCplus_VideoEvents_Smry] ([TSTAMP]) ON [PRIMARY]
GO
