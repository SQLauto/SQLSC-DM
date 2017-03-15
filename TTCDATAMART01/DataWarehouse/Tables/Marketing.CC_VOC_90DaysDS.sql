CREATE TABLE [Marketing].[CC_VOC_90DaysDS]
(
[CustomerID] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC_ContactDate] [datetime] NULL,
[FlagDigitalIssue] [tinyint] NULL,
[FlagEngaged] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagSaved] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketNo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC_ContactYear] [int] NULL,
[CC_ContactMonth] [int] NULL,
[WeekOfContact] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WeekOfOrder] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orders] [int] NULL,
[Sales] [money] NULL,
[OrderedWithinWks] [int] NULL,
[DaysSinceContact] [int] NULL,
[FlagComplete90Days] [int] NOT NULL,
[DateLoaded] [datetime] NOT NULL
) ON [PRIMARY]
GO
