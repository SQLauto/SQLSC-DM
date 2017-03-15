CREATE TABLE [Archive].[CustomerEmailMonthlyCounts]
(
[customerid] [dbo].[udtCustomerID] NOT NULL,
[emailaddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[Cnt] [int] NULL
) ON [PRIMARY]
GO
