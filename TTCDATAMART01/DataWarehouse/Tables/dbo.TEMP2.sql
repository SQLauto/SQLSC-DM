CREATE TABLE [dbo].[TEMP2]
(
[Streamingdate] [date] NULL,
[CustomerID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MagentoUserID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LectureNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AudioVideo] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormatPurchased] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [dbo].[udtSubjectPreference] NULL,
[Transaction_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Platform] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Device] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Action] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_actions] [int] NULL,
[stream_seconds] [float] NULL,
[VideoLength] [float] NULL,
[orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [date] NULL,
[StreamedWebsite] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrevCustomerID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrevMagentoUserID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
