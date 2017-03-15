CREATE TABLE [Archive].[TGCPLUS_ROKUDevice_History]
(
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [bigint] NULL,
[SubDate] [date] NULL,
[SubPlanID] [int] NULL,
[SubPlanName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchSentDate] [date] NULL
) ON [PRIMARY]
GO
