CREATE TABLE [CallCenter].[weeklymetrics3]
(
[Week] [float] NULL,
[Month] [float] NULL,
[Year] [float] NULL,
[Date] [float] NULL,
[Calls Offered,Incoming Calls] [float] NULL,
[Calls Offered, Sales] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Calls Offered, Service] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Calls Offered, UK] [float] NULL,
[Calls Offered, AU] [float] NULL,
[Global Calls Offered] [float] NULL,
[Calls Handled,Incoming Calls] [float] NULL,
[Calls Handled, Sales] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Calls Handled, Service] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Calls Handled, UK] [float] NULL,
[Calls Handled, AU] [float] NULL,
[Global Calls Handled] [float] NULL,
[US Abns] [float] NULL,
[Sales Calls Abandons] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ blankcol] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blankcol2] [float] NULL,
[Sales Abns] [float] NULL,
[Service Abns] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UK Abns] [float] NULL,
[AU Abns] [float] NULL,
[Global Abns] [float] NULL,
[US SL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sales SL] [float] NULL,
[Service SL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[BSC - CPC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BSC - SL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BSC - AHT] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BSC - Cust Sat] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BSC - score CPC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BSC score - SL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BSC score - AHT] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BSC score - Cust Sat] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BSC Weekly] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cost Per Call] [float] NULL,
[AHT Premise] [float] NULL,
[URPO Premise] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AHT ABC] [float] NULL,
[URPO ABC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AHT D] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[URPO D] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[avg ahtd] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[avg urpod] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPOM] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upsell v 2016] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upsell ytd] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upsell to pace] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YTD Upsell URPO] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upsell URPO] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[US Upsell] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UK Upsell] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AU upsell] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[(DAX) URPO Orders] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO