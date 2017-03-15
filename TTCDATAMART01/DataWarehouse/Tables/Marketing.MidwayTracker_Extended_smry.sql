CREATE TABLE [Marketing].[MidwayTracker_Extended_smry]
(
[AsOfDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfYear] [int] NOT NULL,
[AsOfMonth] [int] NOT NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DRTVCust] [int] NOT NULL,
[A12mf] [int] NULL,
[FlagEmailable] [int] NULL,
[FlagEmailPref] [int] NULL,
[FlagValidEmail] [tinyint] NULL,
[FlagMail] [int] NULL,
[Gender] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3OrderSourcePref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgOrderBin] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagFebBuyer] [int] NULL,
[TotalCustomers] [int] NULL,
[PurchAmountSubsqMth] [money] NULL,
[PurchasesSubsqMth] [int] NULL,
[UnitsPurchSubsqMth] [int] NULL,
[PartsPurchSubsqMth] [money] NULL
) ON [PRIMARY]
GO
