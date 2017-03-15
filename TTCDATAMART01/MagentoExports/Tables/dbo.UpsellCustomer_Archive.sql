CREATE TABLE [dbo].[UpsellCustomer_Archive]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SegmentGroup] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateUpdated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UpsellCustomer_Archive] ADD CONSTRAINT [PK_UpsellCustomer_Archive] PRIMARY KEY CLUSTERED  ([CustomerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [UpsellCustomerArchive_Date] ON [dbo].[UpsellCustomer_Archive] ([DateUpdated]) ON [PRIMARY]
GO
