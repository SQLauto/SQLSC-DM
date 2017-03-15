CREATE TABLE [Staging].[Omni_ssis_NonPurchaseCustomerVisits]
(
[customerID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Visits] [int] NULL,
[LastUpdated] [datetime] NULL CONSTRAINT [DF__Omni_ssis__LastU__6328FDA5] DEFAULT (getdate())
) ON [PRIMARY]
GO
