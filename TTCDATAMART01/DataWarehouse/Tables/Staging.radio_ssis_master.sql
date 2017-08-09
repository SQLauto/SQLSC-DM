CREATE TABLE [Staging].[radio_ssis_master]
(
[OfferID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfferCodeDescription] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Program] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Offer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creative] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LandingPageTemplate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumSpots] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDateSpot1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDateSpot2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDateSpot3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDateSpot4] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDateSpot5] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDateSpot6] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDateSpot7] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDateSpot8] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDateSpot9] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDateSpot10] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceCode1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceCode2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceCode3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceCode4] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceCode5] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceCode6] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastDateSpotRun] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartWeek] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartMonth] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartYear] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpirationDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagComplete] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgencyOrDirectBuy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramAbbreviation] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[URLAdvertised] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvertisementType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpotType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpotLength] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpotsPerEpisode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramCategoryOrFormat] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostPerEpisodeOrSOV] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AvgEpisodeImpressions] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPM] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalImpressions] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalCost] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sessions] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinishedRegistration] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SignedUpForSubscription] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostPerSignup] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResponseRate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WebsiteConversionRate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectedRR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectedSignups] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SignupsVariance] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInvoiceSubmitted] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TestOrRenewal] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ControlURLincludingHTML] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCRedirectURLincludingHTML] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO