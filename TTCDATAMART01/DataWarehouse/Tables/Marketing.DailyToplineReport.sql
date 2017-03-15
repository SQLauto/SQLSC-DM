CREATE TABLE [Marketing].[DailyToplineReport]
(
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[WeekOrdered] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [date] NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagFirstOrder] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagDigitalPhysical] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalSales] [money] NULL,
[TotalOrders] [int] NULL,
[TotalTaxes] [money] NULL,
[TotalUnits] [int] NULL,
[TotalParts] [dbo].[udtCourseParts] NULL,
[TranscriptSales] [money] NULL,
[TranscriptUnits] [int] NULL,
[TranscriptParts] [dbo].[udtCourseParts] NULL,
[DigitalSales] [money] NULL,
[DigitalUnits] [int] NULL,
[DigitalParts] [money] NULL,
[PhysicalSales] [money] NULL,
[PhysicalUnits] [int] NULL,
[PhysicalParts] [money] NULL,
[DigitalTranscriptSales] [money] NULL,
[DigitalTranscriptUnits] [int] NULL,
[DigitalTranscriptParts] [dbo].[udtCourseParts] NULL,
[CDSales] [money] NULL,
[CDUnits] [int] NULL,
[CDParts] [money] NULL,
[DVDSales] [money] NULL,
[DVDUnits] [int] NULL,
[DVDParts] [money] NULL,
[AudioTapeSales] [money] NULL,
[AudioTapeUnits] [int] NULL,
[AudioTapeParts] [money] NULL,
[VHSSales] [money] NULL,
[VHSUnits] [int] NULL,
[VHSParts] [money] NULL,
[AudioDLSales] [money] NULL,
[AudioDLUnits] [int] NULL,
[AudioDLParts] [money] NULL,
[VideoDLSales] [money] NULL,
[VideoDLUnits] [int] NULL,
[VideoDLParts] [money] NULL,
[ShippingCharge] [money] NULL,
[DiscountAmount] [money] NULL,
[ReportDate] [datetime] NOT NULL,
[AgeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HouseHoldIncomeBin] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Education] [varchar] (27) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FrequencyPrior] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnlPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewsegPrior] [int] NULL,
[NamePrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mfPrior] [int] NULL,
[MD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Year] [int] NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PriceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelID] [int] NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionTypeID] [int] NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignID] [int] NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPR_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
