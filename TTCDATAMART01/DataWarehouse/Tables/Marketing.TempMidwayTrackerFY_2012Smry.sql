CREATE TABLE [Marketing].[TempMidwayTrackerFY_2012Smry]
(
[AsOfDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfYear] [int] NOT NULL,
[AsOfMonth] [int] NOT NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mf] [int] NULL,
[FlagEmailable] [int] NULL,
[FlagEmailPref] [int] NULL,
[FlagValidEmail] [tinyint] NULL,
[FlagMail] [int] NULL,
[Region] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryPref2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3OrderSourcePref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eWGroup] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TTB_Bin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgOrderBin] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenureBin] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagPrEmailOrder] [tinyint] NULL,
[FlagEngagedCust] [tinyint] NULL,
[FlagBoughtDigitlBfr] [tinyint] NULL,
[SalesBinPriorYr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseCntBinPriorYr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlYear] [int] NULL,
[IntlMonth] [int] NULL,
[IntlSubjectPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlFormatMediaPref] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlOrderSource] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPromotionTypeID] [int] NULL,
[IntlPromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlAvgOrderBin] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectPref2_EOY] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPurchFY] [tinyint] NULL,
[CustCount] [int] NULL,
[PurchAmountFY] [money] NULL,
[PurchasesFY] [int] NULL,
[CourseSalesFY] [money] NULL,
[UnitsPurchFY] [int] NULL,
[PartsPurchFY] [money] NULL,
[EmailSalesFY] [int] NULL,
[EmailOrdersFY] [int] NULL,
[WebSalesFY] [int] NULL,
[WebOrdersFY] [int] NULL,
[MailContactsFY] [int] NULL,
[EmailContactsFY] [money] NULL
) ON [PRIMARY]
GO
