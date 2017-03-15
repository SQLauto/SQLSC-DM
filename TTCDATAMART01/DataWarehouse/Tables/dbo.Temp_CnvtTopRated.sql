CREATE TABLE [dbo].[Temp_CnvtTopRated]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BuyerType] [int] NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concantonated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FMPullDate] [datetime] NULL,
[StartDate] [date] NULL,
[StopDate] [date] NULL,
[Prefix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleInitial] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [nvarchar] (131) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [int] NULL,
[AH] [int] NULL,
[EC] [int] NULL,
[FA] [int] NULL,
[HS] [int] NULL,
[LIT] [int] NULL,
[MH] [int] NULL,
[PH] [int] NULL,
[RL] [int] NULL,
[SC] [int] NULL,
[FlagMail] [int] NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PublicLibrary] [int] NULL,
[FlagValidRegion] [bit] NULL,
[FlagWelcomeBack] [int] NOT NULL,
[CustGroup] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVLVGroup] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AcquisitionWeek] [datetime] NULL,
[VersionName] [varchar] (34) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_Temp_CnvtTopRated] ON [dbo].[Temp_CnvtTopRated] ([CustomerID]) ON [PRIMARY]
GO
