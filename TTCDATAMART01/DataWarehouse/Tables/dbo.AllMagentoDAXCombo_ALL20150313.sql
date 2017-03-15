CREATE TABLE [dbo].[AllMagentoDAXCombo_ALL20150313]
(
[subscriber_email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dax_customer_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[web_user_id] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSince] [datetime] NULL,
[EmailAddress] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagValidEmail] [int] NULL,
[FlagEmailPref] [int] NULL,
[FlagEmailable] [int] NULL,
[JSMERGEDROOT] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSMERGEDPARENT] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Root_CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Root_CustomerSince] [datetime] NULL,
[Root_EmailAddress] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Root_FlagValidEmail] [int] NULL,
[Root_FlagEmailPref] [int] NULL,
[Root_FlagEmailable] [int] NULL,
[FlagRoot] [int] NULL,
[FlagParent] [int] NULL,
[CustType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagProspect] [int] NULL,
[PROSPECTID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProspectEmail] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProspectoptinStatus] [int] NULL,
[EM_subscriber_email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EM_dax_customer_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EM_web_user_id] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccsCustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccsFrequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccsFlagEmail] [int] NULL,
[ccsFlagEmailPref] [int] NULL,
[ccsFlagValidEmail] [int] NULL,
[ccsCountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccsCustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDOrders] [int] NULL,
[LTDSales] [money] NULL,
[MinDateOrdered] [datetime] NULL,
[MaxDateOrdered] [datetime] NULL
) ON [PRIMARY]
GO
