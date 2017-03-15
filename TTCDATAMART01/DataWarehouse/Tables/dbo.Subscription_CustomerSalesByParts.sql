CREATE TABLE [dbo].[Subscription_CustomerSalesByParts]
(
[CustomerID] [int] NOT NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsOfDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sales_2012] [money] NULL,
[Orders_2012] [int] NULL,
[Units_2012] [int] NULL,
[Parts_2012] [money] NULL,
[CourseSales_2012] [money] NULL,
[TranscriptUnits_2012] [int] NULL,
[TranscriptParts_2012] [money] NULL,
[TranscriptSales_2012] [money] NULL,
[PartsBin_2012] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Online_DiAu_Sales_2012] [money] NULL,
[Online_DiVi_Sales_2012] [money] NULL,
[Online_PhAu_Sales_2012] [money] NULL,
[Online_PhVi_Sales_2012] [money] NULL,
[Offline_DiAu_Sales_2012] [money] NULL,
[Offline_DiVi_Sales_2012] [money] NULL,
[Offline_PhAu_Sales_2012] [money] NULL,
[Offline_PhVi_Sales_2012] [money] NULL
) ON [PRIMARY]
GO
