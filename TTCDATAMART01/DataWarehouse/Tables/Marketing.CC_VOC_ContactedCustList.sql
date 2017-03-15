CREATE TABLE [Marketing].[CC_VOC_ContactedCustList]
(
[CustomerID] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatePrepared] [datetime] NULL,
[CC_ContactDate] [datetime] NULL,
[DS90DaysOrders] [int] NULL,
[DS90DaysSales] [money] NOT NULL,
[FlagDS90DaysOrdered] [int] NOT NULL,
[DaysSinceContact] [int] NULL,
[FlagComplete90Days] [int] NOT NULL,
[DateLoaded] [datetime] NOT NULL
) ON [PRIMARY]
GO
