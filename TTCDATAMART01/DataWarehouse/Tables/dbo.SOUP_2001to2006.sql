CREATE TABLE [dbo].[SOUP_2001to2006]
(
[AsOfDate] [smalldatetime] NOT NULL,
[CustomerID] [int] NOT NULL,
[ActiveOrSwamp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SalesSubsqMnth] [money] NULL,
[OrdersSubsqMnth] [int] NULL,
[PartsSubsqMnth] [money] NULL,
[UnitsSubsqMnth] [int] NULL
) ON [PRIMARY]
GO
