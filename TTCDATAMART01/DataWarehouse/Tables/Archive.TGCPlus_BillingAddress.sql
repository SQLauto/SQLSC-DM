CREATE TABLE [Archive].[TGCPlus_BillingAddress]
(
[userId] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[userEmail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userFirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userLastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[line1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[line2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[line3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[county] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[region] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postalCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastUpdateESTDateTime] [datetime] NOT NULL CONSTRAINT [DF__TGCPlus_B__DMLas__2CEE7F33] DEFAULT (getdate())
) ON [PRIMARY]
GO
