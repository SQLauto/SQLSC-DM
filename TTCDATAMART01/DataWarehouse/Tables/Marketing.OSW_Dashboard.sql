CREATE TABLE [Marketing].[OSW_Dashboard]
(
[Year] [int] NOT NULL,
[OSW] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateOrdered] [datetime] NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [int] NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagAudioVideo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagDigitalPhysical] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalOrders] [int] NULL,
[TotalSales] [money] NULL,
[TotalUnits] [int] NULL,
[TotalParts] [dbo].[udtCourseParts] NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncomeDescription] [varchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education] [varchar] (27) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeBin] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Region] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
