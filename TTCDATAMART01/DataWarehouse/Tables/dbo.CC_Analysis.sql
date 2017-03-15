CREATE TABLE [dbo].[CC_Analysis]
(
[Orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagLegacy] [bit] NULL,
[OrderType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[MonthOrdered] [int] NULL,
[YearOrdered] [int] NULL,
[WeekOf] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSRID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasDVD] [int] NOT NULL,
[HasCD] [int] NOT NULL,
[HasAudioDL] [int] NOT NULL,
[HasVideoDL] [int] NOT NULL,
[HasVHS] [int] NOT NULL,
[HasAudioCassette] [int] NOT NULL,
[HasOther] [int] NOT NULL,
[HasTranscript] [int] NULL,
[HasLibraryProd] [int] NULL,
[Flag_AfterFromList] [int] NULL
) ON [PRIMARY]
GO
