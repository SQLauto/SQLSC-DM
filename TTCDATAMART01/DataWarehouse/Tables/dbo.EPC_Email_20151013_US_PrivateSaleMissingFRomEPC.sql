CREATE TABLE [dbo].[EPC_Email_20151013_US_PrivateSaleMissingFRomEPC]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adcode] [int] NULL,
[CustomerSegmentNew] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Mismatch] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustMatch] [int] NOT NULL,
[CustID_CustMatchNEW] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress_CustMatchNEW] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adcode_CustMatchNEW] [int] NULL,
[CustomerSegmentNew_CustMatchNEW] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID_CustMatchNEW] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName_CustMatchNEW] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName_CustMatchNEW] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustID_CustMatchEPC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress_CustMatchEPC] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subscribed_CustMatchEPC] [int] NULL,
[CustMatch2EPC] [int] NOT NULL,
[BounceEPC] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
