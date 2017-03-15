CREATE TABLE [dbo].[DaxAccounts]
(
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSince] [datetime] NOT NULL,
[EmailAddress] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagValidEmail] [int] NOT NULL,
[FlagEmailPref] [int] NOT NULL,
[FlagEmailable] [int] NULL,
[JSMERGEDROOT] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
