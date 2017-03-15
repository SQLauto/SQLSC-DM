CREATE TABLE [Staging].[Weekly_RFM_Report1_Cust]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSince] [datetime] NULL,
[BuyerType] [int] NULL,
[Address1] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mo6InqDate] [datetime] NULL,
[Mo7to24InqDate] [datetime] NULL,
[InqType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip5] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PublicLibrary] [int] NOT NULL,
[OtherInstitutions] [int] NOT NULL,
[LastOrderDate] [datetime] NULL,
[RecentOrderDate] [datetime] NULL,
[Concatenated] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12MF] [int] NOT NULL,
[FlagMail] [int] NOT NULL,
[FlagValidRegion] [int] NOT NULL
) ON [PRIMARY]
GO
