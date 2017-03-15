CREATE TABLE [Archive].[CampaignCustomerSignature20120701]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concatenated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FMPullDate] [datetime] NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prefix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmail] [int] NULL,
[FlagValidEmail] [tinyint] NULL,
[FlagEmailPref] [int] NULL,
[R3PurchWeb] [tinyint] NULL,
[FlagWebLTM18] [tinyint] NULL,
[Address1] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagValidRegionUS] [bit] NULL,
[FlagInternational] [bit] NULL,
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
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [datetime] NULL,
[Age] [int] NULL,
[HouseHoldIncomeRange] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationConfidence] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address3] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FW] [bit] NULL,
[PR] [bit] NULL,
[SCI] [bit] NULL,
[MTH] [bit] NULL,
[VA] [bit] NULL,
[MSC] [bit] NULL,
[Phone] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaFormatPreference] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourcePreference] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecondarySubjPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentNew] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagMailPref] [bit] NULL,
[FlagNonBlankMailAddress] [bit] NULL
) ON [ARCHIVE]
GO
CREATE CLUSTERED INDEX [pkCampaignCustomerSignature20120701CustomerID] ON [Archive].[CampaignCustomerSignature20120701] ([CustomerID]) ON [ARCHIVE]
GO
