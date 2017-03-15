CREATE TABLE [Archive].[RAM_CustomerCohort_Emailtest]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InsertDate] [datetime] NULL,
[CustGroup] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recency] [int] NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnlPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewsegPrior] [int] NULL,
[NamePrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mfPrior] [int] NULL,
[FrequencyPrior] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pricing] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlAdcode] [int] NULL,
[IntlStartDate] [datetime] NULL,
[FlagRemoved] [int] NULL,
[IntlContact] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateRemoved] [date] NULL,
[AdcodeRemoved] [int] NULL
) ON [PRIMARY]
GO
