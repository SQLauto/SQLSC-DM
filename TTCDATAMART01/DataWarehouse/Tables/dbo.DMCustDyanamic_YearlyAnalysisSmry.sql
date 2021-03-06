CREATE TABLE [dbo].[DMCustDyanamic_YearlyAnalysisSmry]
(
[AsOfDate] [date] NOT NULL,
[AsOfYear] [smallint] NOT NULL,
[AsOfMonth] [tinyint] NOT NULL,
[TenureDaysBinID] [tinyint] NOT NULL,
[TenureDaysBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [tinyint] NOT NULL,
[Name] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[A12MF] [tinyint] NOT NULL,
[ActiveOrSwampDesc] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchaseBinID] [tinyint] NOT NULL,
[DSLPurchBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgOrderBin] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3OrderSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3SubjectPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeBin] [varchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EducationBin] [varchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HouseHoldIncomeBin] [varchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustCount] [int] NULL,
[CustCountUniq] [int] NULL,
[Orders] [int] NULL,
[Sales] [money] NULL,
[Parts] [money] NULL,
[units] [int] NULL,
[Sales_Digital] [money] NULL,
[Sales_Physical] [money] NULL,
[SalesWithCoupon] [money] NULL,
[Parts_Digital] [money] NULL,
[Parts_physical] [money] NULL,
[Units_Digital] [int] NULL,
[Units_physical] [int] NULL,
[EmailContacts] [int] NULL,
[MailContacts] [int] NULL,
[SteamedSeconds] [float] NULL,
[TotalActions] [int] NULL,
[StreamSeconds_audio] [float] NULL,
[TotalActions_audio] [int] NULL,
[StreamSeconds_Video] [float] NULL,
[TotalActions_Video] [int] NULL,
[StreamSeconds_Web] [float] NULL,
[TotalActions_Web] [int] NULL,
[StreamSeconds_iOSapp] [float] NULL,
[TotalActions_iOSapp] [int] NULL,
[StreamSeconds_AndroidApp] [float] NULL,
[TotalActions_AndroidApp] [int] NULL
) ON [PRIMARY]
GO
