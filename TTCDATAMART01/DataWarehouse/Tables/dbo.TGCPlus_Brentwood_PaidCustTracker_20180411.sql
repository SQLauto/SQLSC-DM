CREATE TABLE [dbo].[TGCPlus_Brentwood_PaidCustTracker_20180411]
(
[CustomerID] [bigint] NULL,
[IntlSubDate] [date] NULL,
[IntlSubPlanID] [bigint] NULL,
[IntlSubType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CancellationDate] [date] NULL,
[SubDate] [date] NULL,
[SubPlanID] [int] NULL,
[SubType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustStatusFlag] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlMD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagPlanChange] [int] NOT NULL,
[PaymentMonthYear] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentMonth] [int] NULL,
[PaymentYear] [int] NULL,
[charged_amount_currency_code] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalPaid] [float] NULL,
[Service_Period_EndDate] [date] NULL
) ON [PRIMARY]
GO
