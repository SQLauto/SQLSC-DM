CREATE TABLE [CallCenter].[DataWeekly]
(
[Week] [float] NULL,
[Month] [float] NULL,
[Year] [float] NULL,
[Date] [float] NULL,
[Calls Offered,Incoming Calls] [float] NULL,
[Calls Offered, Sales] [float] NULL,
[Calls Offered, Service] [float] NULL,
[Calls Offered, UK] [float] NULL,
[Calls Offered, AU] [float] NULL,
[Global Calls Offered] [float] NULL,
[Calls Handled,Incoming Calls] [float] NULL,
[Calls Handled, Sales] [float] NULL,
[Calls Handled, Service] [float] NULL,
[Calls Handled, UK] [float] NULL,
[Calls Handled, AU] [float] NULL,
[Global Calls Handled] [float] NULL,
[US Abns] [float] NULL,
[Sales Calls Abandons] [float] NULL,
[Blankcol] [float] NULL,
[BlankColu] [float] NULL,
[Sales Abns] [float] NULL,
[Service Abns] [float] NULL,
[UK Abns] [float] NULL,
[AU Abns] [float] NULL,
[Global Abns] [float] NULL,
[US SL] [float] NULL,
[Sales SL] [float] NULL,
[Service SL] [float] NULL,
[UK SL] [float] NULL,
[AU SL] [float] NULL,
[Occupancy, All] [float] NULL,
[Utilization] [float] NULL,
[Sales AHT] [datetime] NULL,
[Sales Talk Time] [datetime] NULL,
[Sales ACW Time] [datetime] NULL,
[Service AHT] [datetime] NULL,
[Service ACD] [datetime] NULL,
[Service ACW] [datetime] NULL,
[Verascape] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VOC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[US Phone to All Ratio] [float] NULL,
[US Calls to Orders] [float] NULL,
[UK Calls to Orders] [float] NULL,
[AUS Calls to Orders] [float] NULL,
[Call Center Sales] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Upsell Conversion] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Upsell Revenue per Call] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Global Mail ] [float] NULL,
[Email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[(URPO)] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[global phone orders] [float] NULL,
[Global AHT] [float] NULL,
[Global AHT (sec)] [float] NULL,
[Global ACD] [float] NULL,
[Global ACD (sec)] [float] NULL,
[Global ACW] [float] NULL,
[Global ACW (sec)] [float] NULL,
[Global Avail] [float] NULL,
[Global Avail (sec)] [float] NULL,
[Global Staffed] [float] NULL,
[Global Staffed (sec)] [float] NULL,
[UK AHT] [float] NULL,
[UK Talk Time] [float] NULL,
[UK ACW Time] [float] NULL,
[AU AHT] [float] NULL,
[AU Talk Time] [float] NULL,
[AU ACW Time] [float] NULL,
[TGC+ AHT] [float] NULL,
[TGC+ Talk Time] [float] NULL,
[TGC+ ACW Time] [float] NULL,
[Calls Offered, TGC+] [float] NULL,
[Calls Handled, TGC+] [float] NULL,
[TGC+ SL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGC+ Abns] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Aftercall Survey] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Aftercall Survey 4-wk rolling] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WFM RSQ] [float] NULL,
[WFM MAPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WFM F/A] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACS by rep] [float] NULL,
[calls to orders] [float] NULL,
[TGC+ Email] [float] NULL,
[BSC - CPC] [float] NULL,
[BSC - SL] [float] NULL,
[BSC - AHT] [datetime] NULL,
[BSC - Cust Sat] [float] NULL,
[BSC - score CPC] [float] NULL,
[BSC score - SL] [float] NULL,
[BSC score - AHT] [float] NULL,
[BSC score - Cust Sat] [float] NULL,
[BSC Weekly] [float] NULL,
[Cost Per Call] [float] NULL,
[AHT Premise] [datetime] NULL,
[URPO Premise] [float] NULL,
[AHT ABC] [float] NULL,
[URPO ABC] [int] NULL,
[AHT D] [int] NULL,
[URPO D] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[avg ahtd] [int] NULL,
[avg urpod] [int] NULL,
[UPOM] [int] NULL,
[upsell v 2016] [int] NULL,
[upsell ytd] [int] NULL,
[upsell to pace] [int] NULL,
[YTD Upsell URPO] [int] NULL,
[upsell URPO] [int] NULL,
[US Upsell] [int] NULL,
[UK Upsell] [int] NULL,
[AU upsell] [int] NULL,
[(DAX) URPO Orders] [int] NULL
) ON [PRIMARY]
GO