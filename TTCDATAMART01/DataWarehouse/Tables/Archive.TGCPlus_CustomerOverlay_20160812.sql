CREATE TABLE [Archive].[TGCPlus_CustomerOverlay_20160812]
(
[CustomerID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchResult] [int] NULL,
[MatchResultDesc] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Income] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncomeDescription] [varchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EducationID] [int] NULL,
[Education] [varchar] (27) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BirthDate_CCYYMM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthYear] [int] NULL,
[BirthMonth] [int] NULL,
[DateOfBirth] [datetime] NULL,
[Gender] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PresenceOfChildren] [varchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NetWorth] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MailOrderBuyer] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RCM_Score] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateFromWD] [datetime] NULL,
[DateUpdated] [datetime] NULL,
[UpdateFromWD] [datetime] NULL,
[WDScore] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WDRawScore] [float] NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address3] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZIP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
