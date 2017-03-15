CREATE TABLE [dbo].[AllMagentoDAXCombo_ByCustomerID]
(
[subscriber_email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscriber_status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dax_customer_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[web_user_id] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSince] [datetime] NULL,
[EmailAddress] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagValidEmail] [int] NULL,
[FlagEmailPref] [int] NULL,
[FlagEmailable] [int] NULL,
[JSMERGEDROOT] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Root_CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Root_CustomerSince] [datetime] NULL,
[Root_EmailAddress] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Root_FlagValidEmail] [int] NULL,
[Root_FlagEmailPref] [int] NULL,
[Root_FlagEmailable] [int] NULL,
[CustType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagProspect] [int] NULL,
[PROSPECTID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProspectEmail] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProspectoptinStatus] [int] NULL
) ON [PRIMARY]
GO
