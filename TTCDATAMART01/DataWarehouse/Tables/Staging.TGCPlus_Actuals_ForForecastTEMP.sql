CREATE TABLE [Staging].[TGCPlus_Actuals_ForForecastTEMP]
(
[AsofDate] [date] NULL,
[AsOfDay] [int] NULL,
[AsOfMonth] [int] NULL,
[AsOfYear] [int] NULL,
[AsOfYrMonth] [varchar] (61) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubDate] [date] NULL,
[IntlSubWeek] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubMonth] [int] NULL,
[IntlSubYear] [int] NULL,
[IntlSubYrMonth] [varchar] (61) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegDate] [date] NULL,
[RegWeek] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegMonth] [int] NULL,
[RegYear] [int] NULL,
[RegYrMonth] [varchar] (61) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [bigint] NULL,
[IntlSubType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubType2] [varchar] (286) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customerStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagDefferedSuspends] [int] NULL,
[SubType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubType2] [varchar] (286) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaidFlag] [int] NULL,
[FlagFirstPaid] [int] NOT NULL,
[CustFlag] [int] NULL,
[CancelTypes] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagBeta] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
