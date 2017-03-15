CREATE TABLE [dbo].[SOUP_1996to2013]
(
[AsOfDate] [date] NOT NULL,
[ActiveOrSwamp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustCount] [int] NULL,
[FlagPurchase] [int] NULL,
[Sales] [money] NULL,
[Orders] [int] NULL,
[Parts] [money] NULL,
[Units] [int] NULL
) ON [PRIMARY]
GO
