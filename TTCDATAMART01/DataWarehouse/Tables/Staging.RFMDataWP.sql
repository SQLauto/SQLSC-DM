CREATE TABLE [Staging].[RFMDataWP]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CountOfOrderID] [int] NULL,
[MaxOfDate] [datetime] NULL,
[SumOfPaymentsToDate] [money] NULL,
[DropDate] [datetime] NULL,
[a12mF_EndDate] [datetime] NULL,
[a12mF_StartDate] [datetime] NULL,
[DSStartDate] [datetime] NULL,
[DSEndDate] [datetime] NULL,
[DSDays] [datetime] NULL,
[DaysOld] [int] NULL,
[AvgOrder] [money] NULL,
[Recency] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MonetaryValue] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concatenated] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mF] [int] NULL,
[CountOfOrderID1] [int] NULL
) ON [PRIMARY]
GO
