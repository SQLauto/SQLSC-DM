CREATE TABLE [Staging].[TempTGCPlus_RadioMaster]
(
[OfferID] [float] NULL,
[OfferCodeDescription] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Program] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Offer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creative] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LandingPageTemplate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumSpots] [float] NULL,
[RunDateSpot1] [datetime] NULL,
[RunDateSpot2] [datetime] NULL,
[RunDateSpot3] [datetime] NULL,
[RunDateSpot4] [datetime] NULL,
[RunDateSpot5] [datetime] NULL,
[RunDateSpot6] [datetime] NULL,
[RunDateSpot7] [datetime] NULL,
[RunDateSpot8] [datetime] NULL,
[RunDateSpot9] [datetime] NULL,
[RunDateSpot10] [datetime] NULL,
[SourceCode1] [float] NULL,
[SourceCode2] [float] NULL,
[SourceCode3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceCode4] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceCode5] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceCode6] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastDateSpotRun] [datetime] NULL,
[StartWeek] [datetime] NULL,
[StartMonth] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartYear] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpirationDate] [datetime] NULL,
[FlagComplete] [float] NULL,
[AgencyOrDirectBuy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramAbbreviation] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[URLAdvertised] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvertisementType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpotType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpotLength] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpotsPerEpisode] [float] NULL,
[ProgramCategoryOrFormat] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostPerEpisodeOrSOV] [money] NULL,
[AvgEpisodeImpressions] [float] NULL,
[CPM] [money] NULL,
[TotalImpressions] [float] NULL,
[TotalCost] [money] NULL,
[Sessions] [float] NULL,
[FinishedRegistration] [float] NULL,
[SignedUpForSubscription] [float] NULL,
[CostPerSignup] [money] NULL,
[ResponseRate] [float] NULL,
[WebsiteConversionRate] [float] NULL,
[ProjectedRR] [float] NULL,
[ProjectedSignups] [float] NULL,
[SignupsVariance] [float] NULL,
[InvoiceNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInvoiceSubmitted] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TestOrRenewal] [float] NULL,
[ControlURLincludingHTML] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCRedirectURLincludingHTML] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
