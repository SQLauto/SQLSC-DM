CREATE TABLE [Mapping].[TGCPlus_InfluencerInput]
(
[UniqueID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Program] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [date] NULL,
[CatalogCode] [int] NULL,
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvertisedURL] [int] NULL,
[ShortURL] [int] NULL,
[TGCRedirect] [int] NULL,
[StartWeek] [date] NULL,
[StartMonth] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StopDate] [date] NULL,
[SpotCost] [money] NULL
) ON [PRIMARY]
GO
