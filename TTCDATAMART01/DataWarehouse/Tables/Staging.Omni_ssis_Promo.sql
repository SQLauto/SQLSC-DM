CREATE TABLE [Staging].[Omni_ssis_Promo]
(
[Date] [datetime] NULL,
[Mobile Device Type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userID (evar29)] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaName (evar34)] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaCompletes (event8)] [int] NULL,
[MediaSegmentViews (event23)] [int] NULL,
[MediaTimePlayed (event22)] [int] NULL,
[MediaViews (event4)] [int] NULL,
[Watched25pct (event24)] [int] NULL,
[Watched50pct (event25)] [int] NULL,
[Watched75pct (event26)] [int] NULL,
[Watched95pct (event27)] [int] NULL
) ON [PRIMARY]
GO
