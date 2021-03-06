CREATE TABLE [Mapping].[TGC_TGCplus]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSince] [datetime] NULL,
[AsOfDate] [date] NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentNew] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFrcst] [varchar] (57) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address3] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postalCode] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCP_ID] [int] NULL,
[TGCP_UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegisteredDate] [datetime] NULL,
[IntlSubscribedDate] [datetime] NULL,
[TGCP_EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeptPin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstCustBUReg] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstCustBUSub] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenureDaysReg] [int] NULL,
[TenureDaysSub] [int] NULL,
[TGCPEmailMatchFlag] [bit] NULL CONSTRAINT [DF__TGC_TGCpl__TGCPE__278D0D9D] DEFAULT ((0)),
[TGCPAddressMatchFlag] [bit] NULL CONSTRAINT [DF__TGC_TGCpl__TGCPA__288131D6] DEFAULT ((0)),
[TGCPurchaseFlag] [bit] NULL CONSTRAINT [DF__TGC_TGCpl__TGCPu__2975560F] DEFAULT ((0)),
[LastUpdatedDate] [datetime] NULL CONSTRAINT [DF__TGC_TGCpl__LastU__2A697A48] DEFAULT (getdate())
) ON [PRIMARY]
GO
