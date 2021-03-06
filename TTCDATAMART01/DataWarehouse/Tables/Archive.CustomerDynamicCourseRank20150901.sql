CREATE TABLE [Archive].[CustomerDynamicCourseRank20150901]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfDate] [smalldatetime] NOT NULL,
[AsOfMonth] [tinyint] NOT NULL,
[AsOfYear] [smallint] NOT NULL,
[LTDPurchases] [int] NULL,
[LTDPurchasesBin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDPurchasesBinOffer] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCat] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRComboID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SecondarySubjPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCatR3] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRComboIDOrig] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchase] [int] NULL,
[DSLNewCoursePur] [int] NULL,
[LTDNewCoursesPur] [int] NULL,
[LTDNewCourseSales] [money] NULL,
[LTDPurchAmount] [money] NULL,
[LTDAvgOrd] [money] NULL,
[TenureDays] [int] NULL,
[FormatMediaCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAVCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3FormatAVPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatADCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3FormatADPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourceCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3OrderSourcePref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TTB] [float] NULL,
[TTB_Bin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [ARCHIVE]
GO
CREATE CLUSTERED INDEX [pkCustomerDynamicCourseRank20150901CustomerID] ON [Archive].[CustomerDynamicCourseRank20150901] ([CustomerID]) ON [ARCHIVE]
GO
