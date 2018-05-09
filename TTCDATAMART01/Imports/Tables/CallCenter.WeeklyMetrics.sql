CREATE TABLE [CallCenter].[WeeklyMetrics]
(
[Week] [int] NULL,
[Month] [int] NULL,
[Year] [int] NULL,
[Date] [date] NULL,
[Calls_OfferedIncoming_Calls] [int] NULL,
[Calls_Offered_Sales] [int] NULL,
[Calls_Offered_Service] [int] NULL,
[Calls_Offered_UK] [int] NULL,
[Calls_Offered_AU] [int] NULL,
[Global_Calls_Offered] [int] NULL,
[Calls_HandledIncoming_Calls] [int] NULL,
[Calls_Handled_Sales] [int] NULL,
[Calls_Handled_Service] [int] NULL,
[Calls_Handled_UK] [int] NULL,
[Calls_Handled_AU] [int] NULL,
[Global_Calls_Handled] [int] NULL,
[US_Abns] [int] NULL,
[Sales_Calls_Abandons] [decimal] (18, 0) NULL,
[Blank1] [decimal] (18, 0) NULL,
[Blank] [decimal] (22, 8) NULL,
[Sales_Abns] [decimal] (22, 8) NULL,
[Service_Abns] [decimal] (22, 8) NULL,
[UK_Abns] [decimal] (22, 8) NULL,
[AU_Abns] [decimal] (22, 8) NULL,
[Global_Abns] [int] NULL,
[US_SL] [decimal] (22, 8) NULL,
[Sales_SL] [decimal] (22, 8) NULL,
[Service_SL] [decimal] (22, 8) NULL,
[UK_SL] [decimal] (22, 8) NULL,
[AU_SL] [decimal] (22, 8) NULL,
[Occupancy_All] [decimal] (22, 8) NULL,
[Utilization] [decimal] (22, 8) NULL,
[Sales_AHT] [time] NULL,
[Sales_Talk_Time] [time] NULL,
[Sales_ACW_Time] [time] NULL,
[Service_AHT] [time] NULL,
[Service_ACD] [time] NULL,
[Service_ACW] [time] NULL,
[Verascape] [decimal] (18, 0) NULL,
[VOC] [money] NULL,
[US_Phone_to_All_Ratio] [decimal] (22, 8) NULL,
[US_Calls_to_Orders] [decimal] (22, 8) NULL,
[UK_Calls_to_Orders] [decimal] (22, 8) NULL,
[AUS_Calls_to_Orders] [decimal] (22, 8) NULL,
[Call_Center_Sales] [money] NULL,
[Upsell_Conversion] [decimal] (22, 8) NULL,
[Upsell_Revenue_per_Call] [money] NULL,
[Global_Mail] [int] NULL,
[Email] [int] NULL,
[URPO] [decimal] (18, 4) NULL,
[global_phone_orders] [int] NULL,
[Global_AHT] [time] NULL,
[Global_AHT_sec] [int] NULL,
[Global_ACD] [time] NULL,
[Global_ACD_sec] [int] NULL,
[Global_ACW] [time] NULL,
[Global_ACW_sec] [int] NULL,
[Global_Avail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[global_Avail_sec] [int] NULL,
[Global_Staffed] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Global_Staffed_sec] [int] NULL,
[UK_AHT] [time] NULL,
[UK_Talk_Time] [time] NULL,
[UK_ACW_Time] [time] NULL,
[AU_AHT] [time] NULL,
[AU_Talk_Time] [time] NULL,
[AU_ACW_Time] [time] NULL,
[TGC+AHT] [time] NULL,
[TGC+Talk_Time] [time] NULL,
[TGC+_ACW_Time] [time] NULL,
[Calls_Offered_TGC+] [int] NULL,
[Calls_Handled_TGC+] [int] NULL,
[TGC+_SL] [decimal] (22, 8) NULL,
[TGC+_Abns] [decimal] (22, 8) NULL,
[Aftercall_Survey] [decimal] (22, 8) NULL,
[Aftercall_Survey_4wk_rolling] [decimal] (22, 8) NULL,
[WFM_RSQ] [decimal] (22, 8) NULL,
[WFM_MAPE] [decimal] (22, 8) NULL,
[WFM_F_A] [decimal] (22, 8) NULL,
[ACS_by_rep] [decimal] (22, 8) NULL,
[calls_to_orders] [decimal] (22, 8) NULL,
[TGC+_Email] [int] NULL,
[BSC_CPC] [money] NULL,
[BSC_SL] [decimal] (22, 8) NULL,
[BSC_AHT] [time] NULL,
[BSC_Cust_Sat] [decimal] (22, 8) NULL,
[BSC_score_CPC] [decimal] (22, 8) NULL,
[BSC_score_SL] [decimal] (22, 8) NULL,
[BSC_score_AHT] [decimal] (22, 8) NULL,
[BSC_score_Cust_Sat] [decimal] (22, 8) NULL,
[BSC_Weekly] [decimal] (22, 8) NULL,
[Cost_Per_Call] [money] NULL,
[AHT_Premise] [time] NULL,
[URPO_Premise] [money] NULL,
[AHT_ABC] [time] NULL,
[URPO_ABC] [money] NULL,
[AHT_D] [decimal] (22, 8) NULL,
[URPO_D] [decimal] (22, 8) NULL,
[avg_ahtd] [decimal] (22, 8) NULL,
[avg_urpod] [decimal] (22, 8) NULL,
[UPOM] [money] NULL,
[upsell_v_2016] [int] NULL,
[upsell_ytd] [money] NULL,
[upsell_to_pace] [int] NULL,
[YTD_Upsell_URPO] [money] NULL,
[upsell_URPO] [money] NULL,
[US_Upsell] [money] NULL,
[UK_Upsell] [money] NULL,
[AU_upsell] [money] NULL,
[DAX_URPO_Orders] [int] NULL,
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__WeeklyMet__DMLas__70A8B9AE] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UC_WeeklyMetrics] ON [CallCenter].[WeeklyMetrics] ([Month], [Year], [Date]) ON [PRIMARY]
GO