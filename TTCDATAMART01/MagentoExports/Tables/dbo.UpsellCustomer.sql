CREATE TABLE [dbo].[UpsellCustomer]
(
[dax_customer_id] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[segmentgroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UpsellCustomer] ADD CONSTRAINT [PK_UpsellCustomer] PRIMARY KEY CLUSTERED  ([dax_customer_id]) ON [PRIMARY]
GO
