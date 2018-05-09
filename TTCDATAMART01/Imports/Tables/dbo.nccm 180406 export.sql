CREATE TABLE [dbo].[nccm 180406 export]
(
[Week] [smallint] NULL,
[Month] [smallint] NULL,
[Year] [smallint] NULL,
[Date] [datetime] NULL,
[Calls_OfferedIncoming_Calls] [real] NULL,
[Calls_Offered_Sales] [real] NULL,
[Calls_Offered_Service] [real] NULL,
[Calls_Offered_UK] [real] NULL,
[Calls_Offered_AU] [real] NULL,
[Global_Calls_Offered] [real] NULL,
[Calls_HandledIncoming_Calls] [real] NULL,
[Calls_Handled_Sales] [real] NULL,
[Calls_Handled_Service] [real] NULL,
[Calls_Handled_UK] [real] NULL,
[Calls_Handled_AU] [real] NULL,
[Global_Calls_Handled] [real] NULL,
[US_Abns] [real] NULL,
[Sales_Calls_Abandons] [smallint] NULL,
[_] [smallint] NULL,
[__] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sales_Abns] [decimal] (28, 0) NULL,
[Service_Abns] [decimal] (28, 0) NULL,
[UK_Abns] [decimal] (28, 0) NULL,
[AU_Abns] [decimal] (28, 0) NULL,
[Global_Abns] [bigint] NULL,
[US_SL] [bigint] NULL,
[Sales_SL] [decimal] (28, 0) NULL,
[Service_SL] [decimal] (28, 0) NULL,
[UK_SL] [decimal] (28, 0) NULL,
[AU_SL] [decimal] (28, 0) NULL,
[Occupancy_All] [decimal] (28, 0) NULL,
[Utilization] [decimal] (28, 0) NULL,
[Sales_AHT] [datetime] NULL,
[Sales_Talk_Time] [datetime] NULL,
[Sales_ACW_Time] [datetime] NULL,
[Service_AHT] [datetime] NULL,
[Service_ACD] [datetime] NULL,
[Service_ACW] [datetime] NULL,
[Verascape] [bigint] NULL,
[VOC] [money] NULL,
[US_Phone_to_All_Ratio] [decimal] (28, 0) NULL,
[US_Calls_to_Orders] [decimal] (28, 0) NULL,
[UK_Calls_to_Orders] [decimal] (28, 0) NULL,
[AUS_Calls_to_Orders] [decimal] (28, 0) NULL,
[Call_Center_Sales] [money] NULL,
[Upsell_Conversion] [decimal] (28, 0) NULL,
[Upsell_Revenue_per_Call] [money] NULL,
[Global_Mail_] [bigint] NULL,
[Email] [bigint] NULL,
[URPO] [real] NULL,
[global_phone_orders] [bigint] NULL,
[Global_AHT] [datetime] NULL,
[Global_AHT_sec] [smallint] NULL,
[Global_ACD] [datetime] NULL,
[Global_ACD_sec] [smallint] NULL,
[Global_ACW] [datetime] NULL,
[Global_ACW_sec] [smallint] NULL,
[Global_Avail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Global_Avail_sec] [int] NULL,
[Global_Staffed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Global_Staffed_sec] [int] NULL,
[UK_AHT] [datetime] NULL,
[UK_Talk_Time] [datetime] NULL,
[UK_ACW_Time] [datetime] NULL,
[AU_AHT] [datetime] NULL,
[AU_Talk_Time] [datetime] NULL,
[AU_ACW_Time] [datetime] NULL,
[TGC+_AHT] [datetime] NULL,
[TGC+_Talk_Time] [datetime] NULL,
[TGC+_ACW_Time] [datetime] NULL,
[Calls_Offered_TGC+] [bigint] NULL,
[Calls_Handled_TGC+] [bigint] NULL,
[TGC+_SL] [decimal] (28, 0) NULL,
[TGC+_Abns] [decimal] (28, 0) NULL,
[Aftercall_Survey] [real] NULL,
[Aftercall_Survey_4-wk_rolling] [real] NULL,
[WFM_RSQ] [real] NULL,
[WFM_MAPE] [decimal] (28, 0) NULL,
[WFM_FA] [decimal] (28, 0) NULL,
[ACS_by_rep] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calls_to_orders] [decimal] (28, 0) NULL,
[TGC+_Email] [smallint] NULL,
[BSC_-_CPC] [money] NULL,
[BSC_-_SL] [decimal] (28, 0) NULL,
[BSC_-_AHT] [time] (0) NULL,
[BSC_-_Cust_Sat] [decimal] (28, 0) NULL,
[BSC_-_score_CPC] [decimal] (28, 0) NULL,
[BSC_score_-_SL] [decimal] (28, 0) NULL,
[BSC_score_-_AHT] [decimal] (28, 0) NULL,
[BSC_score_-_Cust_Sat] [decimal] (28, 0) NULL,
[BSC_Weekly] [decimal] (28, 0) NULL,
[Cost_Per_Call] [money] NULL,
[AHT_Premise] [datetime] NULL,
[URPO_Premise] [money] NULL,
[AHT_ABC] [datetime] NULL,
[URPO_ABC] [money] NULL,
[AHT_D] [decimal] (28, 0) NULL,
[URPO_D] [decimal] (28, 0) NULL,
[avg_ahtd] [decimal] (28, 0) NULL,
[avg_urpod] [decimal] (28, 0) NULL,
[UPOM] [money] NULL,
[upsell_v_2016] [money] NULL,
[upsell_ytd] [money] NULL,
[upsell_to_pace] [money] NULL,
[YTD_Upsell_URPO] [money] NULL,
[upsell_URPO] [money] NULL,
[US_Upsell] [money] NULL,
[UK_Upsell] [money] NULL,
[AU_upsell] [money] NULL,
[(DAX)_URPO_Orders] [bigint] NULL
) ON [PRIMARY]
GO