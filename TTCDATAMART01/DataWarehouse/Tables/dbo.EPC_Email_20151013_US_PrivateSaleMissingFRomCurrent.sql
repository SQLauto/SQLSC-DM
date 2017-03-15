CREATE TABLE [dbo].[EPC_Email_20151013_US_PrivateSaleMissingFRomCurrent]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[adcode] [int] NULL,
[CustomerSegmentNew] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Mismatch] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustMatch] [int] NOT NULL,
[CustID_CustMatchOLD] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress_CustMatchOLD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adcode_CustMatchOLD] [int] NULL,
[CustomerSegmentNew_CustMatchOLD] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID_CustMatchOLD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName_CustMatchOLD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName_CustMatchOLD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustID_CustMatchCCS] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress_CustMatchCCS] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmailPref_CustMatchCCS] [int] NULL,
[FlagEmail_CustMatchCCS] [int] NULL,
[CustomerSegmentNew_CustMatchCCS] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID_CustMatchCCS] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
