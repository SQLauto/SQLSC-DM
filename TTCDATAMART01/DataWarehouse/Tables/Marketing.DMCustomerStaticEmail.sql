CREATE TABLE [Marketing].[DMCustomerStaticEmail]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSince] [datetime] NULL,
[EmailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstUsedAdcode] [int] NULL,
[BuyerType] [int] NULL,
[CustGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailPreferenceID] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailPreferenceValue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmailable] [int] NULL,
[MailPreferenceID] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailPreferenceValue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UseForBilling] [tinyint] NULL,
[DatePulled] [datetime] NOT NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
