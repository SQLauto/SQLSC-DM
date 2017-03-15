CREATE TABLE [Mapping].[FBA_Customer_Address]
(
[FBA_AddressID] [int] NOT NULL IDENTITY(10001, 1),
[buyer_email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recipient_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_address_1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_address_2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_address_3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_city] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_postal_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Initialpurchase_date] [date] NULL,
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__FBA_Custo__DMLas__3A5694A5] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[FBA_Customer_Address] ADD CONSTRAINT [PK__FBA_Cust__9092BA1860357B14] PRIMARY KEY CLUSTERED  ([FBA_AddressID]) ON [PRIMARY]
GO
