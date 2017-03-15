CREATE TABLE [dbo].[AllDAXAccounts]
(
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSince] [datetime] NOT NULL,
[EmailAddress] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagValidEmail] [int] NOT NULL,
[FlagEmailPref] [int] NOT NULL,
[FlagEmailable] [int] NULL,
[JSMERGEDROOT] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Root_CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Root_CustomerSince] [datetime] NULL,
[Root_EmailAddress] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Root_FlagValidEmail] [int] NULL,
[Root_FlagEmailPref] [int] NULL,
[Root_FlagEmailable] [int] NULL
) ON [PRIMARY]
GO
