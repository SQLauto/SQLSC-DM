CREATE TABLE [Staging].[CCUpsellRecos]
(
[CustomerID] [dbo].[udtCustomerID] NOT NULL,
[CourseID] [int] NOT NULL,
[Rank] [smallint] NULL,
[LastOrderDate] [datetime] NULL
) ON [PRIMARY]
GO
