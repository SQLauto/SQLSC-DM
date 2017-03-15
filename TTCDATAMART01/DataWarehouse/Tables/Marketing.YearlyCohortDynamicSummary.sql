CREATE TABLE [Marketing].[YearlyCohortDynamicSummary]
(
[FlagMailableCollegeBuyerSS] [tinyint] NOT NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsOfDate] [date] NOT NULL,
[AsOfMonth] [tinyint] NOT NULL,
[AsOfYear] [smallint] NOT NULL,
[NewSeg] [tinyint] NOT NULL,
[Name] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[A12MF] [tinyint] NOT NULL,
[ActiveOrSwamp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ActiveOrSwampDesc] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FrequencyDesc] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDPurchasesBinID] [tinyint] NOT NULL,
[LTDPurchasesBin] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchaseBinID] [tinyint] NOT NULL,
[DSLPurchBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgOrderBinID] [tinyint] NOT NULL,
[LTDAvgOrdBin] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDFormatMediaCat] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3FormatMediaPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDFormatAVCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatAVPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LTDFormatADCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatADPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LTDSubjectCat] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3SubjectPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDOrderSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3OrderSource] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenureDaysBinID] [tinyint] NOT NULL,
[TenureDaysBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDCouponsRedmBinID] [tinyint] NOT NULL,
[LTDCouponsRedmpBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLCouponRedmBinID] [tinyint] NOT NULL,
[DSLCouponRedeemedBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDReturnsBinID] [tinyint] NOT NULL,
[LTDReturnsBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDEMResponsesBinID] [tinyint] NOT NULL,
[LTDEMResponsesBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLEMResponseBinID] [tinyint] NOT NULL,
[DSLEMResponseBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDNewCoursePurchBinID] [tinyint] NOT NULL,
[LTDNewCoursePurchBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLNewCoursePurchBinID] [tinyint] NOT NULL,
[DSLNewCoursePurchasedBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmailPref] [tinyint] NULL,
[FlagEmailValid] [tinyint] NULL,
[FlagEmailable] [tinyint] NULL,
[FlagMailPref] [tinyint] NULL,
[FlagValidUSMailable] [tinyint] NULL,
[FlagMailable] [tinyint] NULL,
[FlagMailableDescription] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3PurchWeb] [tinyint] NULL,
[CustomerSegment2ID] [int] NULL,
[CustomerSegment2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegmentFnlID] [int] NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeBin] [varchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EducationBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg_EOY] [tinyint] NULL,
[Name_EOY] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12MF_EOY] [tinyint] NULL,
[ActiveOrSwamp_EOY] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency_EOY] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment2ID_EOY] [int] NULL,
[CustomerSegment2_EOY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegmentFnlID_EOY] [int] NULL,
[CustomerSegmentFnl_EOY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalesSubsqYr] [money] NULL,
[OrdersSubsqYr] [int] NULL,
[UnitsSubsqYr] [int] NULL,
[PartsSubsqYr] [dbo].[udtCourseParts] NULL,
[EMSalesSubsqYr] [money] NULL,
[EMOrdersSubsqYr] [int] NULL,
[CustCount] [int] NULL
) ON [PRIMARY]
GO
