CREATE TABLE [Marketing].[TGCplus_VideoEvents_Smry_TestAccts]
(
[UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [bigint] NOT NULL,
[TSTAMP] [date] NULL,
[Month] [int] NULL,
[Year] [int] NULL,
[Week] [int] NULL,
[Platform] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[useragent] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[courseid] [bigint] NULL,
[episodeNumber] [bigint] NULL,
[FilmType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lectureRunTime] [bigint] NULL,
[CountryCode] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timezone] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plays] [int] NULL,
[pings] [int] NULL,
[MaxVPOS] [bigint] NULL,
[uip] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StreamedMins] [numeric] (12, 1) NULL,
[MinTstamp] [datetime] NULL,
[SeqNum] [int] NULL
) ON [PRIMARY]
GO
