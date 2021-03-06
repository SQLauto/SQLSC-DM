CREATE TABLE [dbo].[Analysis_CustSpending_OrdersSmry]
(
[AsOfDate] [smalldatetime] NOT NULL,
[AsOfMonth] [tinyint] NOT NULL,
[AsOfYear] [smallint] NOT NULL,
[NewSeg] [tinyint] NOT NULL,
[Name] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[A12MF] [tinyint] NOT NULL,
[ActiveOrSwamp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatAVPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatADPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3SubjectPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3OrderSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagEmailable] [tinyint] NULL,
[FlagMailable] [tinyint] NULL,
[TTB_Bin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationConfidence] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDPurchasesBin] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSLPurchaseBin] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDAvgOrderBin] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenureDaysBin] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[PromotionTypeFlag] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagAudioVideo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagDigitalPhysical] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalOrders] [int] NULL,
[TotalSales] [money] NULL,
[FinalSales] [money] NULL,
[ShippingCharge] [money] NULL,
[Tax] [money] NULL,
[DiscountAmount] [money] NULL,
[TotalCourseParts] [money] NULL,
[TotalCourseQuantity] [int] NULL,
[TotalCourseSales] [money] NULL,
[TotalTranscriptParts] [money] NULL,
[TotalTranscriptQuantity] [int] NULL,
[TotalTranscriptSales] [money] NULL,
[PricingDiscount] [money] NULL
) ON [PRIMARY]
GO
