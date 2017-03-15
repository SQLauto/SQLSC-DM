CREATE TABLE [Archive].[CampaignCustomerSignature20110401]
(
[Customerid] [int] NOT NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concantonated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FMPullDate] [datetime] NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prefix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleInitial] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmail] [int] NULL,
[FlagValidEmail] [tinyint] NULL,
[FlagEmailPref] [int] NULL,
[R3OrderSource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[R3PurchWeb] [tinyint] NULL,
[FlagWebLTM18] [tinyint] NULL,
[Address1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCodeOrig] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagValidRegion] [int] NULL,
[FlagIntNtnl] [tinyint] NULL,
[Zip5] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagMail] [int] NULL,
[FirstUsedAdcode] [int] NULL,
[BuyerType] [int] NULL,
[CustomerType] [tinyint] NULL,
[CustomerSince] [datetime] NULL,
[LastOrderDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[InqDate6Mo] [datetime] NULL,
[InqDate7_12Mo] [datetime] NULL,
[InqDate12_24Mo] [datetime] NULL,
[FlagInq] [int] NULL,
[InqType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstInq] [int] NULL,
[DRTVInq] [int] NULL,
[PublicLibrary] [int] NULL,
[OtherInstitution] [int] NULL,
[Gender] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CG_Gender] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LTDPurchasesBin] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRComboID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumHits] [int] NULL,
[AH] [int] NULL,
[EC] [int] NULL,
[FA] [int] NULL,
[HS] [int] NULL,
[LIT] [int] NULL,
[MH] [int] NULL,
[PH] [int] NULL,
[RL] [int] NULL,
[SC] [int] NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
