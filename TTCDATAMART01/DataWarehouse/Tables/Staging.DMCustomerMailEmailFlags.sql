CREATE TABLE [Staging].[DMCustomerMailEmailFlags]
(
[AsOfDate] [datetime] NULL,
[CustomerID] [dbo].[udtCustomerID] NOT NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmailable] [int] NULL,
[FlagValidEmail] [tinyint] NULL,
[FlagEmailPref] [int] NULL,
[FlagValidRegion] [int] NULL,
[FlagMailPref] [int] NULL,
[PublicLibrary] [int] NULL,
[FlagMailable] [int] NULL,
[CountryCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3PurchWeb] [tinyint] NULL,
[CountryCodeCube] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
