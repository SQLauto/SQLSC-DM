CREATE TABLE [Amazon].[Returns]
(
[Order_Return_ID] [int] NOT NULL IDENTITY(1, 1),
[DateKey] [date] NULL,
[return_date] [datetimeoffset] (2) NULL,
[amazon_order_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_sku] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_asin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_fnsku] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [decimal] (10, 2) NULL,
[return_fulfillment_center_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[return_detailed_disposition] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[return_reason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[return_status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Import_Timestamp] [datetime] NULL CONSTRAINT [DF__Returns__Import___1CF15040] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Amazon].[Returns] ADD CONSTRAINT [PK__Returns__6283081AC34751D6] PRIMARY KEY CLUSTERED  ([Order_Return_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [Amazon].[Returns] TO [ebridge]
GO
GRANT INSERT ON  [Amazon].[Returns] TO [ebridge]
GO
