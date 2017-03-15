CREATE TABLE [Legacy].[InvalidEmails]
(
[CustomerID] [dbo].[udtCustomerID] NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_InvalidEmails_CustomerID] ON [Legacy].[InvalidEmails] ([CustomerID]) INCLUDE ([EmailAddress]) ON [PRIMARY]
GO
