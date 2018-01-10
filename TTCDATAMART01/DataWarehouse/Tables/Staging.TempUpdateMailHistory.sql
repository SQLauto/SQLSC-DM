CREATE TABLE [Staging].[TempUpdateMailHistory]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyerType] [int] NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[Concatenated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FMPullDate] [datetime] NULL,
[StartDate] [datetime] NULL,
[Prefix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [nvarchar] (131) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [int] NULL,
[FlagMail] [int] NULL,
[Gender] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NumHits] [int] NULL,
[NumHitsCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubjMatch] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Score] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CG_Gender] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSince] [datetime] NULL,
[DSLPurchase] [int] NULL,
[Recency] [int] NULL,
[IntlAOS] [money] NULL,
[IntlOrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlFormat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPromotionTypeID] [smallint] NULL,
[CustomerSegmentNew] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmail] [int] NULL,
[TenureDays] [int] NULL,
[LTDPurchases] [int] NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TTB] [float] NULL,
[AH] [int] NULL,
[EC] [int] NULL,
[FA] [int] NULL,
[HS] [int] NULL,
[LIT] [int] NULL,
[MH] [int] NULL,
[PH] [int] NULL,
[RL] [int] NULL,
[SC] [int] NULL,
[FW] [int] NULL,
[PR] [int] NULL,
[SCI] [int] NULL,
[MTH] [int] NULL,
[VA] [int] NULL,
[MSC] [int] NULL,
[SubjRank] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3OrderSourcePref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecencyBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgAOS_Bin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eWGroup] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTD_LVHV_Flag] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmailOrder] [int] NULL,
[DRTV] [int] NULL,
[S1Orders] [int] NULL,
[MTHCourses] [int] NULL,
[EmailOrderPrefFlag] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnsubFlag] [int] NULL,
[NoEmailFlag] [int] NULL,
[PriorPurchaseOrderID] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorPurchaseOrderDate] [date] NULL,
[PriorPurchaseOrderAmount] [money] NULL,
[PriorPurchaseOrderSource] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorPurchaseAdcode] [int] NULL,
[CustomerSegmentPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment2Prior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnlPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FrequencyPrior] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewsegPrior] [int] NULL,
[NamePrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mfPrior] [int] NULL,
[PriorSales] [money] NULL,
[PriorOrders] [int] NULL,
[PriorAOS] [money] NULL,
[ConcatenatedPrior] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecencyPrior] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MonetaryValuePrior] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prior12MonthOrders] [int] NULL,
[Prior6MonthOrders] [int] NULL,
[RAMSelect] [int] NULL,
[EmailWebPrefFlag] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SelectFlag] [int] NULL,
[LastOrderDate] [date] NULL,
[CV_FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C1V_CourseID] [int] NULL,
[C1V_CourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C1V_PageNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C1V_CouponCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C1V_DollarOff] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseParts] [tinyint] NULL,
[C1V_SaveUpto] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Decile] [int] NULL,
[DemiDecile] [int] NULL
) ON [PRIMARY]
GO
