CREATE TABLE [Marketing].[TGCPlus_Actuals_ForForecast_BKP20161130]
(
[AsofDate] [date] NULL,
[AsOfDay] [int] NULL,
[AsOfMonth] [int] NULL,
[AsOfYear] [int] NULL,
[IntlSubDate] [date] NULL,
[IntlSubWeek] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubMonth] [int] NULL,
[IntlSubYear] [int] NULL,
[CustomerID] [bigint] NULL,
[IntlSubType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customerStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagDefferedSuspends] [int] NULL,
[SubType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaidFlag] [int] NULL,
[CustFlag] [int] NOT NULL,
[CancelTypes] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagBeta] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
