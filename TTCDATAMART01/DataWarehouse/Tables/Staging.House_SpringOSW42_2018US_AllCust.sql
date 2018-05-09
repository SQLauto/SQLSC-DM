CREATE TABLE [Staging].[House_SpringOSW42_2018US_AllCust]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Prefix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegment] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateLastPurchased] [datetime] NULL
) ON [PRIMARY]
GO
