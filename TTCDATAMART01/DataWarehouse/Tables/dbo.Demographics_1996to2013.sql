CREATE TABLE [dbo].[Demographics_1996to2013]
(
[AsOfDate] [smalldatetime] NOT NULL,
[CustomerID] [int] NOT NULL,
[ActiveOrSwamp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SalesSubsqMnth] [money] NULL,
[OrdersSubsqMnth] [int] NULL,
[PartsSubsqMnth] [money] NULL,
[UnitsSubsqMnth] [int] NULL,
[HouseHoldIncomeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseHoldIncomeRange] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [datetime] NULL,
[Age] [int] NULL,
[AgeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
