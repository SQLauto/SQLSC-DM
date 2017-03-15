CREATE TABLE [Staging].[TempCC_VOC_ContactedCustList]
(
[CustomerID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC_ContactDate] [datetime] NULL,
[FlagDigitalIssue] [float] NULL,
[FlagEngaged] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagSaved] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
