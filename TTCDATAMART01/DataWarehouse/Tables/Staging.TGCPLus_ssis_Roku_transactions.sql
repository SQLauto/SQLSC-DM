CREATE TABLE [Staging].[TGCPLus_ssis_Roku_transactions]
(
[event_date] [datetime] NULL,
[invoice_number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transaction_type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[developer_transaction_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_transaction_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip_code] [float] NULL,
[channel_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [float] NULL,
[amount] [float] NULL,
[service_credits] [float] NULL,
[net_amount] [float] NULL,
[currency] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expiration_date] [datetime] NULL,
[original_transaction_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[partner_reference_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[refund_description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comments] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
