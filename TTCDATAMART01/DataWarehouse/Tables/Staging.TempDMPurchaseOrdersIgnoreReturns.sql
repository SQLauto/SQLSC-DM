CREATE TABLE [Staging].[TempDMPurchaseOrdersIgnoreReturns]
(
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[SequenceNum] [int] NULL,
[DownStreamDays] [int] NULL,
[DaysSinceLastPurchase] [int] NULL,
[CSRID] [int] NULL,
[CSRID_actual] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NULL,
[AdCode] [int] NULL,
[PromotionType] [smallint] NULL,
[FlagCouponRedm] [tinyint] NULL,
[DiscountAmount] [money] NULL,
[MinShipDate] [smalldatetime] NULL,
[MaxShipDate] [smalldatetime] NULL,
[OrderShipDays] [int] NULL,
[FlagSplitShipment] [tinyint] NULL,
[NetOrderAmount] [money] NULL,
[ShippingCharge] [money] NULL,
[Tax] [money] NULL,
[FinalSales] [money] NULL,
[TotalCourseQuantity] [int] NULL,
[TotalCourseParts] [dbo].[udtCourseParts] NULL,
[TotalCourseSales] [money] NULL,
[TotalTranscriptQuantity] [int] NULL,
[TotalTranscriptParts] [dbo].[udtCourseParts] NULL,
[TotalTranscriptSales] [money] NULL,
[NextPurchaseOrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NextPurchaseOrderDate] [smalldatetime] NULL,
[NextPurchaseOrderAmount] [money] NULL,
[NextPurchaseOrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NextPurchaseAdcode] [int] NULL,
[PriorPurchaseOrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorPurchaseOrderDate] [smalldatetime] NULL,
[PriorPurchaseOrderAmount] [money] NULL,
[PriorPurchaseOrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorPurchaseAdcode] [int] NULL,
[FlagLowPriceLeader] [tinyint] NULL,
[BillingCountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagDVDatCDProspect] [tinyint] NULL,
[FlagEmailOrder] [tinyint] NULL,
[CustomerSegmentPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[FlagLegacy] [bit] NULL,
[Prior12MonthOrders] [int] NULL,
[Prior6MonthOrders] [int] NULL,
[WebOrderID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusCode] [int] NULL,
[CurrencyCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalesTypeID] [int] NULL,
[Age] [int] NULL,
[AgeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagDigitalPhysical] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagAudioVideo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagHasCLRCourse] [bit] NULL,
[TotalCLRCourseSales] [money] NULL,
[TotalCLRCourseUnits] [int] NULL,
[TotalCLRCourseParts] [money] NULL,
[FlagHasOtherCourse] [bit] NULL,
[TotalOtherCourseSales] [money] NULL,
[TotalOtherCourseUnits] [int] NULL,
[TotalOtherCourseParts] [money] NULL,
[StandardSalePriceAllCourses] [money] NULL,
[StandardSalePriceCLRCourses] [money] NULL,
[StandardSalePriceOtherCourses] [money] NULL,
[TotalCourseSalesWthSets] [money] NULL,
[TotalCourseQuantityWthSets] [int] NULL,
[TotalCoursePartsWthSets] [dbo].[udtCourseParts] NULL,
[TotalCLRCourseSalesWthSets] [money] NULL,
[TotalCLRCourseUnitsWthSets] [int] NULL,
[TotalCLRCoursePartsWthSets] [dbo].[udtCourseParts] NULL,
[TotalOtherCourseSalesWthSets] [money] NULL,
[TotalOtherCourseUnitsWthSets] [int] NULL,
[TotalOtherCoursePartsWthSets] [dbo].[udtCourseParts] NULL,
[StandardSalePriceCourseWthSets] [money] NULL,
[StdSalePriceCLRCourseWthSets] [money] NULL,
[StdSalePriceOtherCourseWthSets] [money] NULL,
[CustomerSegment2Prior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnlPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GiftFlag] [bit] NULL,
[ShipRegion] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipCountryCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingRegion] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coupon] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CouponDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorL2PurchaseOrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentPriorL2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FrequencyPriorL2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewsegPriorL2] [int] NULL,
[NamePriorL2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mfPriorL2] [int] NULL,
[CustomerSegment2PriorL2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnlPriorL2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalDigitalCourseSales] [money] NULL,
[TotalDigitalCourseUnits] [int] NULL,
[TotalDigitalCourseParts] [money] NULL,
[TotalPhysicalCourseSales] [money] NULL,
[TotalPhysicalCourseUnits] [int] NULL,
[TotalPhysicalCourseParts] [money] NULL,
[TotalDigitalTranscriptQuantity] [int] NULL,
[TotalDigitalTranscriptParts] [dbo].[udtCourseParts] NULL,
[TotalDigitalTranscriptSales] [money] NULL
) ON [PRIMARY]
GO
