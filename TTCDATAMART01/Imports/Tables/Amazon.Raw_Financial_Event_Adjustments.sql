CREATE TABLE [Amazon].[Raw_Financial_Event_Adjustments]
(
[OrderItemId] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdjustmentType] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[API_Log_ID] [bigint] NULL,
[Import_Timestamp] [datetime] NULL
) ON [PRIMARY]
GO
