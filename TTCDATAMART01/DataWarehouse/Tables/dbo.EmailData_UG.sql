CREATE TABLE [dbo].[EmailData_UG]
(
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Min_Startdate] [datetime2] (3) NULL,
[Max_Startdate] [datetime2] (3) NULL,
[EmailsSent] [int] NULL,
[EPCEmails] [int] NULL,
[EmailSalesAmount] [money] NULL,
[EmailOrders] [int] NULL,
[MinEmailOrderDate] [datetime2] (3) NULL,
[LastEmailOrderDate] [datetime2] (3) NULL,
[CatalogSalesAmount] [money] NULL,
[CatalogOrders] [int] NULL,
[MinCatalogOrderDate] [datetime2] (3) NULL,
[LastCatalogOrderDate] [datetime2] (3) NULL,
[TotalAmount] [money] NULL,
[Orders] [int] NULL,
[Min_Dateordred] [datetime2] (3) NULL,
[Max_Dateordred] [datetime2] (3) NULL,
[Age] [int] NULL,
[AgeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeRange] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
