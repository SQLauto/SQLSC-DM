CREATE TABLE [Staging].[EmailPullDLR]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Unsubscribe] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailStatus] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubjectLine] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustHTML] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[State] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SendDate] [int] NULL,
[ECampaignID] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeadlineDate] [nvarchar] (65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subject] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegmentNew] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserID] [varchar] (26) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
