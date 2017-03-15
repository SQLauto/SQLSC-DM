CREATE TABLE [Archive].[Omni_Streaming_history]
(
[Omni_Streaming_history_id] [int] NOT NULL IDENTITY(1, 1),
[Streamingdate] [date] NOT NULL,
[CustomerID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lecture_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AudioVideo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Platform] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Device] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Action] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalActions] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StreamSeconds] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StockItemID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Omni_Streaming_history] ADD CONSTRAINT [PK__Omni_Str__92DB40E706F05FAE] PRIMARY KEY CLUSTERED  ([Omni_Streaming_history_id]) ON [PRIMARY]
GO
