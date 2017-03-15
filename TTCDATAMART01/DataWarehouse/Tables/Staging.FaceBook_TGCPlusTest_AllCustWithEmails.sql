CREATE TABLE [Staging].[FaceBook_TGCPlusTest_AllCustWithEmails]
(
[Subscribed] [int] NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BounceFlag] [int] NOT NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegmentPriority] [int] NULL,
[CustType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustGroup] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnlFB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustSegComboForRNDMZ] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
