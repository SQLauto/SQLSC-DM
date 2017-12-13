CREATE TABLE [Marketing].[MonthlyEmailCounts]
(
[Customerid] [dbo].[udtCustomerID] NOT NULL,
[Year] [int] NULL,
[Month] [int] NULL,
[EmailContacts] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UC_MonthlyEMailCounts] ON [Marketing].[MonthlyEmailCounts] ([Customerid], [Year], [Month]) ON [PRIMARY]
GO
