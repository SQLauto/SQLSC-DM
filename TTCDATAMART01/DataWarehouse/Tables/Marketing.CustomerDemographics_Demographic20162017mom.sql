CREATE TABLE [Marketing].[CustomerDemographics_Demographic20162017mom]
(
[AsofDate] [date] NOT NULL,
[CustomerSegment] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EducationBin] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AgeBin] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gender] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Countrycode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMediaPref] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCatPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCatPrefDesc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourcePref] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagMailable] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmailable] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDPurchasesBin] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgOrderBin] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenureDaysBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustCount] [int] NULL,
[PurchAmountSubsqMth] [money] NULL,
[PurchasesSubsqMth] [int] NULL,
[PartsPurchSubsqMth] [dbo].[udtCourseParts] NULL,
[UnitsPurchSubsqMth] [int] NULL
) ON [PRIMARY]
GO
