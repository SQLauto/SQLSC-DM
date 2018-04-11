CREATE TABLE [Staging].[TGCPlus_freedays]
(
[Customerid] [bigint] NULL,
[service_period_from] [datetime] NULL,
[Freedays] [int] NULL,
[FreedaysBucket] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DMLAstupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
