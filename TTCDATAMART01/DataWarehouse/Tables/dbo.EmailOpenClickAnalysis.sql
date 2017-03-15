CREATE TABLE [dbo].[EmailOpenClickAnalysis]
(
[AsOfDate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentNew] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationConfidence] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[Countrycode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmail] [int] NULL,
[IntlAvgOrderBin_2] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Intl_CourseCategory] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlFormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSinceBin] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AcqstnYear] [int] NULL,
[AcqstnMonth] [int] NULL,
[FlagEmailOrderPast3Mnth] [int] NOT NULL,
[FlagOtherOrderPast3Mnth] [int] NOT NULL,
[FlagEmailOrderDS] [int] NOT NULL,
[FlagOtherOrderDS] [int] NOT NULL,
[R3SubjectPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3OrderSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3PurchWeb] [tinyint] NULL,
[LTDAvgOrdBin] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDPurchasesBin] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagOpens_Past1Month] [int] NOT NULL,
[FlagClicks_Past1Month] [int] NOT NULL,
[FlagOpens_Past2Month] [int] NOT NULL,
[FlagClicks_Past2Month] [int] NOT NULL,
[FlagOpens_Past3Month] [int] NOT NULL,
[FlagClicks_Past3Month] [int] NOT NULL,
[FlagOpensAllID] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagOpensAll] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagClicksAllID] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagClicksAll] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustCount] [int] NULL,
[TotalEmailOrdersPast3Mnth] [int] NULL,
[TotalEmailSalesPast3Mnth] [money] NULL,
[TotalOtherOrdersPast3Mnth] [int] NULL,
[TotalOtherSalesPast3Mnth] [money] NULL,
[TotalEmailOrdersDS] [int] NULL,
[TotalEmailSalesDS] [money] NULL,
[TotalOtherOrdersDS] [int] NULL,
[TotalOtherSalesDS] [money] NULL
) ON [PRIMARY]
GO
