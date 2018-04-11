CREATE TABLE [CallCenter].[DataWeeklyMetrics]
(
[Week] [float] NULL,
[Month] [float] NULL,
[Year] [float] NULL,
[Date] [date] NULL,
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
[Blank1] [float] NULL,
[blank2] [float] NULL,
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
[Sales_AHT] [time] NULL,
[Sales_Talk_Time] [time] NULL,
[Sales_ACW_Time] [time] NULL,
[Service_AHT] [time] NULL,
[Service_ACD] [time] NULL,
[Service_ACW] [time] NULL,
[Verascape] [float] NULL,
[VOC] [float] NULL,
[US Phone to All Ratio] [float] NULL,
[US Calls to Orders] [float] NULL,
[UK Calls to Orders] [float] NULL,
[AUS Calls to Orders] [float] NULL,
[Call Center Sales] [float] NULL,
[Upsell Conversion] [float] NULL,
[Upsell Revenue per Call] [float] NULL,
[Global Mail ] [float] NULL,
[Email] [float] NULL,
[(URPO)] [float] NULL,
[global phone orders] [float] NULL,
[Global_AHT] [time] NULL,
[Global AHT (sec)] [float] NULL,
[Global_ACD] [time] NULL,
[Global ACD (sec)] [float] NULL,
[Global_ACW] [time] NULL,
[Global ACW (sec)] [float] NULL,
[Global_Avail] [time] NULL,
[Global Avail (sec)] [float] NULL,
[Global_Staffed] [time] NULL,
[Global Staffed (sec)] [float] NULL,
[UK_AHT] [time] NULL,
[UK_Talk_Time] [time] NULL,
[UK_ACW_Time] [time] NULL,
[AU_AHT] [time] NULL,
[AU_Talk_Time] [time] NULL,
[AU_ACW_Time] [time] NULL,
[TGC+AHT] [time] NULL,
[TGC+TalkTime] [time] NULL,
[TGC+ACWTime] [time] NULL,
[Calls Offered, TGC+] [float] NULL,
[Calls Handled, TGC+] [float] NULL,
[TGC+ SL] [float] NULL,
[TGC+ Abns] [float] NULL,
[Aftercall Survey] [float] NULL,
[Aftercall Survey 4-wk rolling] [float] NULL,
[WFM RSQ] [float] NULL,
[WFM MAPE] [float] NULL,
[WFM F/A] [float] NULL,
[ACS by rep] [float] NULL,
[calls to orders] [float] NULL,
[TGC+ Email] [float] NULL,
[BSC - CPC] [float] NULL,
[BSC_SL] [time] NULL,
[BSC_AHT] [time] NULL,
[BSC - Cust Sat] [float] NULL,
[BSC - score CPC] [float] NULL,
[BSC score - SL] [float] NULL,
[BSC score - AHT] [float] NULL,
[BSC score - Cust Sat] [float] NULL,
[BSC Weekly] [float] NULL,
[Cost Per Call] [float] NULL,
[AHT_PREMISE] [time] NULL,
[URPO Premise] [float] NULL,
[AHT_ABC] [time] NULL,
[URPO ABC] [float] NULL,
[AHT D] [float] NULL,
[URPO D] [float] NULL,
[avg ahtd] [float] NULL,
[avg urpod] [float] NULL,
[UPOM] [float] NULL,
[upsell v 2016] [float] NULL,
[upsell ytd] [float] NULL,
[upsell to pace] [float] NULL,
[YTD Upsell URPO] [float] NULL,
[upsell URPO] [float] NULL,
[US Upsell] [float] NULL,
[UK Upsell] [float] NULL,
[AU upsell] [float] NULL,
[(DAX) URPO Orders] [float] NULL
) ON [PRIMARY]
GO
