CREATE TABLE [Marketing].[Upsell_CustomerSegmentGroup]
(
[CustomerID] [dbo].[udtCustomerID] NULL,
[SegmentGroup] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOrderDate] [date] NULL,
[LastUpdateDate] [date] NULL
) ON [PRIMARY]
GO
