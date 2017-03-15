CREATE TABLE [dbo].[AllDAXMagentoCombo_ByEmail]
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
[Root_FlagEmailable] [int] NULL,
[subscriber_email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscriber_status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dax_customer_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[web_user_id] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagRoot] [int] NULL,
[FlagNumChained] [int] NULL,
[FlagNumParents] [int] NULL
) ON [PRIMARY]
GO
