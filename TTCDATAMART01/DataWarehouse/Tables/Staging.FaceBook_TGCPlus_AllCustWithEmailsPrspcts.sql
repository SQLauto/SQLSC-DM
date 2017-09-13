CREATE TABLE [Staging].[FaceBook_TGCPlus_AllCustWithEmailsPrspcts]
(
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[firstname] [int] NULL,
[lastname] [int] NULL,
[city] [int] NULL,
[state] [int] NULL,
[postalcode] [int] NULL,
[CountryCode] [int] NULL,
[CustomerSegmentFnl] [int] NULL,
[CustomerSegmentFnlFB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
