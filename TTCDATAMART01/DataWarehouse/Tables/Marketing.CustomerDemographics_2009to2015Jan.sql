CREATE TABLE [Marketing].[CustomerDemographics_2009to2015Jan]
(
[AsofDate] [date] NOT NULL,
[CustomerSegment] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LTDAvgOrdBin] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormMediaPref] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3SubjecPref] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3OrderSourcePref] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmailPref] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagValidEmail] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagEmailable] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagMailable] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EducationBin] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AgeBin] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gender] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Countrycode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustCount] [int] NULL,
[PurchAmountSubsqMth] [money] NULL,
[PurchasesSubsqMth] [int] NULL,
[PartsPurchSubsqMth] [money] NULL,
[UnitsPurchSubsqMth] [int] NULL
) ON [PRIMARY]
GO
