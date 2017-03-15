CREATE TABLE [Staging].[Email_20170212_DP_US_FormatSale_01]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Unsubscribe] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailStatus] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectLine] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustHTML] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdCode] [int] NULL,
[PreferredCategory] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SendDate] [int] NULL,
[BatchID] [tinyint] NULL,
[ECampaignID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeadlineDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subject] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentNew] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserID] [nvarchar] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewSeg] [int] NULL,
[Format] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboidPrior] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
