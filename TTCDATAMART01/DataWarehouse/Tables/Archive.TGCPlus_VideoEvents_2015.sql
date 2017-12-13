CREATE TABLE [Archive].[TGCPlus_VideoEvents_2015]
(
[aid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pfm] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origip] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tstamp] [datetime] NULL,
[useragent] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[url] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pa] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vpos] [bigint] NULL,
[apos] [bigint] NULL,
[apod] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dp1] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dp2] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dp3] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dp4] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dp5] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[continent] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryname] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryisocode] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cityname] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[latitude] [real] NULL,
[longitude] [real] NULL,
[timezone] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subdivision1] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subdivision2] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subdivision3] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uip] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastUpdateESTDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TGCPlus_VideoEvents_2015_Tstamp] ON [Archive].[TGCPlus_VideoEvents_2015] ([tstamp]) ON [PRIMARY]
GO