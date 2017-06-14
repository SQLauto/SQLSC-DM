CREATE TABLE [Staging].[TempTGCDigitalConsumption]
(
[DigitalConsumptionHistory_ID] [int] NOT NULL IDENTITY(1, 1),
[StreamingDate] [date] NOT NULL,
[CustomerID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AudioVideo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatPurchased] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [dbo].[udtSubjectPreference] NULL,
[TransactionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Platform] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Device] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Action] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalActions] [int] NULL,
[StreamSeconds] [float] NULL,
[OrderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StockItemID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[StreamedWebsite] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrevCustomerID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MagentoUserID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VideoLength] [float] NULL,
[PrevMagentoUserID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
