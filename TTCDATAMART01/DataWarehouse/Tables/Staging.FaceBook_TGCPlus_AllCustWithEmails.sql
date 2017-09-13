CREATE TABLE [Staging].[FaceBook_TGCPlus_AllCustWithEmails]
(
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[firstname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postalcode] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnlFB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
