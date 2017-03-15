CREATE TABLE [Staging].[CC_VOC_ContactedCustList]
(
[CustomerID] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC_ContactDate] [datetime] NULL,
[FlagDigitalIssue] [tinyint] NULL,
[FlagEngaged] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagSaved] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketNo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
