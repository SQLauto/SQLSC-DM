CREATE TABLE [Archive].[RAM_EmailHistory]
(
[CustomerID] [dbo].[udtCustomerID] NOT NULL,
[Adcode] [int] NULL,
[StartDate] [datetime] NULL,
[Comboid] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboidPrior] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
