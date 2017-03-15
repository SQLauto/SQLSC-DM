CREATE TABLE [Archive].[CustomerOverlay_WD_20150323_1]
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
[WDRawScore] [float] NULL
) ON [PRIMARY]
GO
