CREATE TABLE [dbo].[DigialCust_analysis_20170111Smry]
(
[CustSegmentAsOfDate] [date] NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[MediaFormatPreference] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaFormatPreferenceFLIP] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PDPref] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PDPrefFLIP] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustGroupPD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FmtPD_DigitalOnly] [int] NULL,
[FmtPD_PhysicalOnly] [int] NULL,
[FmtPD_BothDgtlPhscl] [int] NULL,
[FmtPD_None] [int] NULL,
[FmtPD_Digital] [int] NULL,
[FmtPD_Physical] [int] NULL,
[FmtAV_VideoOnly] [int] NULL,
[FmtAV_AudioOnly] [int] NULL,
[FmtAV_BothAudioVidoe] [int] NULL,
[FmtAV_None] [int] NULL,
[FmtAV_Video] [int] NULL,
[FmtAV_Audio] [int] NULL,
[FMT_DigitalAudio] [int] NULL,
[FMT_DVD] [int] NULL,
[FMT_CD] [int] NULL,
[FMT_DigitalVideo] [int] NULL,
[FMT_Transcript] [int] NULL,
[FMT_DigitalTranscript] [int] NULL,
[Source_Web] [int] NULL,
[Source_NonWeb] [int] NULL,
[TGCPlusCustID] [bigint] NULL,
[TGCPlusCustStatusFlag] [float] NULL,
[TGCPlusSubDate] [date] NULL,
[TGCPlusSubPlanID] [int] NULL,
[TGCPlusSubPlanName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlusSubType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagTGCPlusCust] [int] NOT NULL,
[FlagStreamedTGC] [int] NOT NULL,
[CustCount] [int] NULL,
[Units_DigitalAudio] [int] NULL,
[Units_DVD] [int] NULL,
[Units_CD] [int] NULL,
[Units_DigitalVideo] [int] NULL,
[Units_Transcript] [int] NULL,
[Units_DigitalTranscript] [int] NULL,
[Units_Digital] [int] NULL,
[Units_Physical] [int] NULL,
[Units_Video] [int] NULL,
[Units_Audio] [int] NULL,
[Sales_DigitalAudio] [money] NULL,
[Sales_DVD] [money] NULL,
[Sales_CD] [money] NULL,
[Sales_DigitalVideo] [money] NULL,
[Sales_Transcript] [money] NULL,
[Sales_DigitalTranscript] [money] NULL,
[Sales_Digital] [money] NULL,
[Sales_Physical] [money] NULL,
[Sales_Video] [money] NULL,
[Sales_Audio] [money] NULL,
[TotalSalesOrd] [money] NULL,
[TotalOrders] [int] NULL,
[TotalCourseSales] [money] NULL,
[TotalCourseQuantity] [int] NULL,
[TotalTranscriptSales] [money] NULL,
[TotalTranscriptQuantity] [int] NULL,
[ShippingCharge] [money] NULL,
[DiscountAmount] [money] NULL,
[Tax] [money] NULL,
[NetMinusShip] [money] NULL,
[Sales_Web] [numeric] (38, 5) NULL,
[Sales_NonWeb] [numeric] (38, 5) NULL
) ON [PRIMARY]
GO
