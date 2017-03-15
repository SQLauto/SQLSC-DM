CREATE TABLE [Archive].[Mail_US_DecCatalog_20161111]
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
[R3OrderSourcePref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecencyBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgAOS_Bin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eWGroup] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTD_LVHV_Flag] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NonEngagedFlag] [int] NULL,
[FlagEmailOrder] [int] NULL,
[DRTV] [int] NULL,
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
[Decile] [int] NULL,
[DemiDecile] [int] NULL,
[RAMSelect] [int] NULL,
[NovAdcode] [int] NULL,
[LastOrderDate] [date] NULL
) ON [PRIMARY]
GO
