CREATE TABLE [dbo].[AllDAX_NotInMagentoByEmail20150313]
(
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSince] [datetime] NOT NULL,
[EmailAddress] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagValidEmail] [int] NOT NULL,
[FlagEmailPref] [int] NOT NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orders] [int] NULL,
[Sales] [money] NULL,
[DigitalOrders] [int] NULL,
[DigitalSales] [money] NULL,
[MinOrderDate] [datetime] NULL,
[MaxOrderDate] [datetime] NULL,
[FlagDigital] [int] NOT NULL,
[FlagOmni] [int] NOT NULL,
[FlagCustMatch] [int] NOT NULL
) ON [PRIMARY]
GO
