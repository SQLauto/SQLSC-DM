CREATE TABLE [Staging].[MktFraudCustomers]
(
[CustomerID] [dbo].[udtCustomerID] NOT NULL,
[Address1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleInitial] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateAdded] [datetime] NULL,
[ReasonAdded] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
