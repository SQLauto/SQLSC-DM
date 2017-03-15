CREATE TABLE [Staging].[Customers]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RootCustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyerType] [int] NULL,
[CustomerSince] [datetime] NULL,
[FirstName] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prefix] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address3] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceCustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerType] [int] NULL,
[LastUpdated] [datetime] NULL,
[AddressModifiedDate] [datetime] NULL,
[JSCUSTSTATUS] [int] NULL,
[Phone] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstUsedAdCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSMERGEDPARENT] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyName] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MergedCustomerID] [dbo].[udtCustomerID] NULL,
[CustomerSinceGMT] [datetime] NULL,
[LastUpdatedGMT] [datetime] NULL,
[AddressModifiedDateGMT] [datetime] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idxCustomers_CustomerID] ON [Staging].[Customers] ([CustomerID]) INCLUDE ([RootCustomerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxCustomers_MergedCustomerID] ON [Staging].[Customers] ([MergedCustomerID]) ON [PRIMARY]
GO
