SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[CallCenter_Weekly_Clean_Import]
as
	update  Imports.staging.WeeklyMetrics						 set [Week]	=		Replace([Week],',','')
       update  Imports.staging.WeeklyMetrics				  set [Month]	=		Replace([Month],',','')
   update  Imports.staging.WeeklyMetrics				      set [Year]	=		Replace([Year],',','')
   update  Imports.staging.WeeklyMetrics				      set [Date]	=		Replace([Date],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_OfferedIncoming_Calls]	=		Replace([Calls_OfferedIncoming_Calls],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_Sales]	=		Replace([Calls_Offered_Sales],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_Service]	=		Replace([Calls_Offered_Service],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_UK]	=		Replace([Calls_Offered_UK],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_AU]	=		Replace([Calls_Offered_AU],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Calls_Offered]=			Replace([Global_Calls_Offered],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_HandledIncoming_Calls]	=		Replace([Calls_HandledIncoming_Calls],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_Sales]	=		Replace([Calls_Handled_Sales],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_Service]	=		Replace([Calls_Handled_Service],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_UK]	=		Replace([Calls_Handled_UK],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_AU]	=		Replace([Calls_Handled_AU],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Calls_Handled]	=		Replace([Global_Calls_Handled],',','')
   update  Imports.staging.WeeklyMetrics				      set [US_Abns]			=Replace([US_Abns],',','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_Calls_Abandons]			=Replace([Sales_Calls_Abandons],',','')
   update  Imports.staging.WeeklyMetrics				      set [_]	=		Replace([_],',','')
   update  Imports.staging.WeeklyMetrics				      set [__]	=		Replace([__],',','')
   update  Imports.staging.WeeklyMetrics				  set [Sales_Abns] 		=	Replace([Sales_Abns],',','')
   update  Imports.staging.WeeklyMetrics				      set [Service_Abns]		=	Replace([Service_Abns],',','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Abns]		=	Replace([UK_Abns],',','')
   update  Imports.staging.WeeklyMetrics				      set [AU_Abns]		=	Replace([AU_Abns],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Abns]		=	Replace([Global_Abns],',','')
   update  Imports.staging.WeeklyMetrics				      set [US_SL]		=	Replace([US_SL],',','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_SL]		=	Replace([Sales_SL],',','')
   update  Imports.staging.WeeklyMetrics				      set [Service_SL]		=	Replace([Service_SL],',','')
   update  Imports.staging.WeeklyMetrics				      set [UK_SL]		=	Replace([UK_SL],',','')
   update  Imports.staging.WeeklyMetrics				      set [AU_SL]		=	Replace([AU_SL],',','')
   update  Imports.staging.WeeklyMetrics				      set [Occupancy_All]		=	Replace([Occupancy_All],',','')
   update  Imports.staging.WeeklyMetrics				      set [Utilization]		=	Replace([Utilization],',','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_AHT]		=	Replace([Sales_AHT],',','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_Talk_Time]		=	Replace([Sales_Talk_Time],',','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_ACW_Time]		=	Replace([Sales_ACW_Time],',','')
   update  Imports.staging.WeeklyMetrics				      set [Service_AHT]		=	Replace([Service_AHT],',','')
   update  Imports.staging.WeeklyMetrics				      set [Service_ACD]		=	Replace([Service_ACD],',','')
   update  Imports.staging.WeeklyMetrics				      set [Service_ACW]		=	Replace([Service_ACW],',','')
   update  Imports.staging.WeeklyMetrics				      set [Verascape]		=	Replace([Verascape],',','')
   update  Imports.staging.WeeklyMetrics				      set [VOC]		=	Replace([VOC],',','')
   update  Imports.staging.WeeklyMetrics				      set [US_Phone_to_All_Ratio]		=	Replace([US_Phone_to_All_Ratio],',','')
   update  Imports.staging.WeeklyMetrics				      set [US_Calls_to_Orders]		=	Replace([US_Calls_to_Orders],',','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Calls_to_Orders]		=	Replace([UK_Calls_to_Orders],',','')
   update  Imports.staging.WeeklyMetrics				      set [AUS_Calls_to_Orders]		=	Replace([AUS_Calls_to_Orders],',','')
   update  Imports.staging.WeeklyMetrics				      set [Call_Center_Sales]		=	Replace([Call_Center_Sales],',','')
   update  Imports.staging.WeeklyMetrics				      set [Upsell_Conversion]		=	Replace([Upsell_Conversion],',','')
   update  Imports.staging.WeeklyMetrics				      set [Upsell_Revenue_per_Call]		=	Replace([Upsell_Revenue_per_Call],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Mail_]		=	Replace([Global_Mail_],',','')
   update  Imports.staging.WeeklyMetrics				      set [Email]		=	Replace([Email],',','')
   update  Imports.staging.WeeklyMetrics				      set [(URPO)]		=	Replace([(URPO)],',','')
   update  Imports.staging.WeeklyMetrics				      set [global_phone_orders]		=	Replace([global_phone_orders],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_AHT]		=	Replace([Global_AHT],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_AHT_(sec)]		=	Replace([Global_AHT_(sec)],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACD]		=	Replace([Global_ACD],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACD_(sec)]		=	Replace([Global_ACD_(sec)],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACW]		=	Replace([Global_ACW],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACW_(sec)]		=	Replace([Global_ACW_(sec)],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Avail]		=	Replace([Global_Avail],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Avail_(sec)]		=	Replace([Global_Avail_(sec)],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Staffed]		=	Replace([Global_Staffed],',','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Staffed_(sec)]		=	Replace([Global_Staffed_(sec)],',','')
   update  Imports.staging.WeeklyMetrics				      set [UK_AHT]		=	Replace([UK_AHT],',','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Talk_Time]		=	Replace([UK_Talk_Time],',','')
   update  Imports.staging.WeeklyMetrics				      set [UK_ACW_Time]		=	Replace([UK_ACW_Time],',','')
   update  Imports.staging.WeeklyMetrics				      set [AU_AHT]		=	Replace([AU_AHT],',','')
   update  Imports.staging.WeeklyMetrics				      set [AU_Talk_Time]		=	Replace([AU_Talk_Time],',','')
   update  Imports.staging.WeeklyMetrics				      set [AU_ACW_Time]		=	Replace([AU_ACW_Time],',','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_AHT]		=	Replace([TGC+_AHT],',','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_Talk_Time]		=	Replace([TGC+_Talk_Time],',','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_ACW_Time]		=	Replace([TGC+_ACW_Time],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_TGC+]		=	Replace([Calls_Offered_TGC+],',','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_TGC+]		=	Replace([Calls_Handled_TGC+],',','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_SL]		=	Replace([TGC+_SL],',','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_Abns]		=	Replace([TGC+_Abns],',','')
   update  Imports.staging.WeeklyMetrics				      set [Aftercall_Survey]		=	Replace([Aftercall_Survey],',','')
   update  Imports.staging.WeeklyMetrics				      set [Aftercall_Survey_4-wk_rolling]		=	Replace([Aftercall_Survey_4-wk_rolling],',','')
update  Imports.staging.WeeklyMetrics				      set [WFM_RSQ]		=	Replace([WFM_RSQ],',','')
   update  Imports.staging.WeeklyMetrics				      set [WFM_MAPE]		=	Replace([WFM_MAPE],',','')
   update  Imports.staging.WeeklyMetrics				      set [WFM_F A]		=	Replace([WFM_F A],',','')
   update  Imports.staging.WeeklyMetrics				      set [ACS_by_rep]		=	Replace([ACS_by_rep],',','')
   update  Imports.staging.WeeklyMetrics				      set [calls_to_orders]		=	Replace([calls_to_orders],',','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_Email]		=	Replace([TGC+_Email],',','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_CPC]		=	Replace([BSC_-_CPC],',','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_SL]		=	Replace([BSC_-_SL],',','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_AHT]		=	Replace([BSC_-_AHT],',','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_Cust_Sat]		=	Replace([BSC_-_Cust_Sat],',','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_score_CPC]		=	Replace([BSC_-_score_CPC],',','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_score_-_SL]		=	Replace([BSC_score_-_SL],',','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_score_-_AHT]		=	Replace([BSC_score_-_AHT],',','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_score_-_Cust_Sat]		=	Replace([BSC_score_-_Cust_Sat],',','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_Weekly]		=	Replace([BSC_Weekly],',','')
   update  Imports.staging.WeeklyMetrics				      set [Cost_Per_Call]		=	Replace([Cost_Per_Call],',','')
   update  Imports.staging.WeeklyMetrics				      set [AHT_Premise]		=	Replace([AHT_Premise],',','')
   update  Imports.staging.WeeklyMetrics				      set [URPO_Premise]		=	Replace([URPO_Premise],',','')
   update  Imports.staging.WeeklyMetrics				      set [AHT_ABC]		=	Replace([AHT_ABC],',','')
   update  Imports.staging.WeeklyMetrics				      set [URPO_ABC]		=	Replace([URPO_ABC],',','')
   update  Imports.staging.WeeklyMetrics				      set [AHT_D]		=	Replace([AHT_D],',','')
   update  Imports.staging.WeeklyMetrics				      set [URPO_D]		=	Replace([URPO_D],',','')
   update  Imports.staging.WeeklyMetrics				      set [avg_ahtd]		=	Replace([avg_ahtd],',','')
   update  Imports.staging.WeeklyMetrics				      set [avg_urpod]		=	Replace([avg_urpod],',','')
   update  Imports.staging.WeeklyMetrics				      set [UPOM]		=	Replace([UPOM],',','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_v_2016]		=	Replace([upsell_v_2016],',','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_ytd]		=	Replace([upsell_ytd],',','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_to_pace]		=	Replace([upsell_to_pace],',','')
   update  Imports.staging.WeeklyMetrics				      set [YTD_Upsell_URPO]		=	Replace([YTD_Upsell_URPO],',','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_URPO]		=	Replace([upsell_URPO],',','')
   update  Imports.staging.WeeklyMetrics				      set [US_Upsell]		=	Replace([US_Upsell],',','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Upsell]		=	Replace([UK_Upsell],',','')
   update  Imports.staging.WeeklyMetrics				      set [AU_upsell]		=	Replace([AU_upsell],',','')
   update  Imports.staging.WeeklyMetrics				      set [(DAX)_URPO_Orders]		=	Replace([(DAX)_URPO_Orders],',','')



  update  Imports.staging.WeeklyMetrics							set [Week]	=		Replace([Week],'$','')
       update  Imports.staging.WeeklyMetrics				  set [Month]	=		Replace([Month],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Year]	=		Replace([Year],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Date]	=		Replace([Date],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_OfferedIncoming_Calls]	=		Replace([Calls_OfferedIncoming_Calls],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_Sales]	=		Replace([Calls_Offered_Sales],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_Service]	=		Replace([Calls_Offered_Service],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_UK]	=		Replace([Calls_Offered_UK],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_AU]	=		Replace([Calls_Offered_AU],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Calls_Offered]=			Replace([Global_Calls_Offered],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_HandledIncoming_Calls]	=		Replace([Calls_HandledIncoming_Calls],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_Sales]	=		Replace([Calls_Handled_Sales],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_Service]	=		Replace([Calls_Handled_Service],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_UK]	=		Replace([Calls_Handled_UK],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_AU]	=		Replace([Calls_Handled_AU],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Calls_Handled]	=		Replace([Global_Calls_Handled],'$','')
   update  Imports.staging.WeeklyMetrics				      set [US_Abns]			=Replace([US_Abns],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_Calls_Abandons]			=Replace([Sales_Calls_Abandons],'$','')
   update  Imports.staging.WeeklyMetrics				      set [_]	=		Replace([_],'$','')
   update  Imports.staging.WeeklyMetrics				      set [__]	=		Replace([__],'$','')
   update  Imports.staging.WeeklyMetrics				  set [Sales_Abns] 		=	Replace([Sales_Abns],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Service_Abns]		=	Replace([Service_Abns],'$','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Abns]		=	Replace([UK_Abns],'$','')
   update  Imports.staging.WeeklyMetrics				      set [AU_Abns]		=	Replace([AU_Abns],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Abns]		=	Replace([Global_Abns],'$','')
   update  Imports.staging.WeeklyMetrics				      set [US_SL]		=	Replace([US_SL],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_SL]		=	Replace([Sales_SL],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Service_SL]		=	Replace([Service_SL],'$','')
   update  Imports.staging.WeeklyMetrics				      set [UK_SL]		=	Replace([UK_SL],'$','')
   update  Imports.staging.WeeklyMetrics				      set [AU_SL]		=	Replace([AU_SL],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Occupancy_All]		=	Replace([Occupancy_All],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Utilization]		=	Replace([Utilization],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_AHT]		=	Replace([Sales_AHT],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_Talk_Time]		=	Replace([Sales_Talk_Time],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_ACW_Time]		=	Replace([Sales_ACW_Time],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Service_AHT]		=	Replace([Service_AHT],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Service_ACD]		=	Replace([Service_ACD],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Service_ACW]		=	Replace([Service_ACW],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Verascape]		=	Replace([Verascape],'$','')
   update  Imports.staging.WeeklyMetrics				      set [VOC]		=	Replace([VOC],'$','')
   update  Imports.staging.WeeklyMetrics				      set [US_Phone_to_All_Ratio]		=	Replace([US_Phone_to_All_Ratio],'$','')
   update  Imports.staging.WeeklyMetrics				      set [US_Calls_to_Orders]		=	Replace([US_Calls_to_Orders],'$','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Calls_to_Orders]		=	Replace([UK_Calls_to_Orders],'$','')
   update  Imports.staging.WeeklyMetrics				      set [AUS_Calls_to_Orders]		=	Replace([AUS_Calls_to_Orders],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Call_Center_Sales]		=	Replace([Call_Center_Sales],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Upsell_Conversion]		=	Replace([Upsell_Conversion],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Upsell_Revenue_per_Call]		=	Replace([Upsell_Revenue_per_Call],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Mail_]		=	Replace([Global_Mail_],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Email]		=	Replace([Email],'$','')
   update  Imports.staging.WeeklyMetrics				      set [(URPO)]		=	Replace([(URPO)],'$','')
   update  Imports.staging.WeeklyMetrics				      set [global_phone_orders]		=	Replace([global_phone_orders],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_AHT]		=	Replace([Global_AHT],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_AHT_(sec)]		=	Replace([Global_AHT_(sec)],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACD]		=	Replace([Global_ACD],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACD_(sec)]		=	Replace([Global_ACD_(sec)],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACW]		=	Replace([Global_ACW],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACW_(sec)]		=	Replace([Global_ACW_(sec)],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Avail]		=	Replace([Global_Avail],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Avail_(sec)]		=	Replace([Global_Avail_(sec)],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Staffed]		=	Replace([Global_Staffed],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Staffed_(sec)]		=	Replace([Global_Staffed_(sec)],'$','')
   update  Imports.staging.WeeklyMetrics				      set [UK_AHT]		=	Replace([UK_AHT],'$','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Talk_Time]		=	Replace([UK_Talk_Time],'$','')
   update  Imports.staging.WeeklyMetrics				      set [UK_ACW_Time]		=	Replace([UK_ACW_Time],'$','')
   update  Imports.staging.WeeklyMetrics				      set [AU_AHT]		=	Replace([AU_AHT],'$','')
   update  Imports.staging.WeeklyMetrics				      set [AU_Talk_Time]		=	Replace([AU_Talk_Time],'$','')
   update  Imports.staging.WeeklyMetrics				      set [AU_ACW_Time]		=	Replace([AU_ACW_Time],'$','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_AHT]		=	Replace([TGC+_AHT],'$','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_Talk_Time]		=	Replace([TGC+_Talk_Time],'$','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_ACW_Time]		=	Replace([TGC+_ACW_Time],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_TGC+]		=	Replace([Calls_Offered_TGC+],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_TGC+]		=	Replace([Calls_Handled_TGC+],'$','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_SL]		=	Replace([TGC+_SL],'$','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_Abns]		=	Replace([TGC+_Abns],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Aftercall_Survey]		=	Replace([Aftercall_Survey],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Aftercall_Survey_4-wk_rolling]		=	Replace([Aftercall_Survey_4-wk_rolling],'$','')
   update  Imports.staging.WeeklyMetrics				      set [WFM_RSQ]		=	Replace([WFM_RSQ],'$','')
   update  Imports.staging.WeeklyMetrics				      set [WFM_MAPE]		=	Replace([WFM_MAPE],'$','')
   update  Imports.staging.WeeklyMetrics				      set [WFM_F A]		=	Replace([WFM_F A],'$','')
   update  Imports.staging.WeeklyMetrics				      set [ACS_by_rep]		=	Replace([ACS_by_rep],'$','')
   update  Imports.staging.WeeklyMetrics				      set [calls_to_orders]		=	Replace([calls_to_orders],'$','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_Email]		=	Replace([TGC+_Email],'$','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_CPC]		=	Replace([BSC_-_CPC],'$','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_SL]		=	Replace([BSC_-_SL],'$','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_AHT]		=	Replace([BSC_-_AHT],'$','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_Cust_Sat]		=	Replace([BSC_-_Cust_Sat],'$','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_score_CPC]		=	Replace([BSC_-_score_CPC],'$','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_score_-_SL]		=	Replace([BSC_score_-_SL],'$','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_score_-_AHT]		=	Replace([BSC_score_-_AHT],'$','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_score_-_Cust_Sat]		=	Replace([BSC_score_-_Cust_Sat],'$','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_Weekly]		=	Replace([BSC_Weekly],'$','')
   update  Imports.staging.WeeklyMetrics				      set [Cost_Per_Call]		=	Replace([Cost_Per_Call],'$','')
   update  Imports.staging.WeeklyMetrics				      set [AHT_Premise]		=	Replace([AHT_Premise],'$','')
   update  Imports.staging.WeeklyMetrics				      set [URPO_Premise]		=	Replace([URPO_Premise],'$','')
   update  Imports.staging.WeeklyMetrics				      set [AHT_ABC]		=	Replace([AHT_ABC],'$','')
   update  Imports.staging.WeeklyMetrics				      set [URPO_ABC]		=	Replace([URPO_ABC],'$','')
   update  Imports.staging.WeeklyMetrics				      set [AHT_D]		=	Replace([AHT_D],'$','')
   update  Imports.staging.WeeklyMetrics				      set [URPO_D]		=	Replace([URPO_D],'$','')
   update  Imports.staging.WeeklyMetrics				      set [avg_ahtd]		=	Replace([avg_ahtd],'$','')
   update  Imports.staging.WeeklyMetrics				      set [avg_urpod]		=	Replace([avg_urpod],'$','')
   update  Imports.staging.WeeklyMetrics				      set [UPOM]		=	Replace([UPOM],'$','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_v_2016]		=	Replace([upsell_v_2016],'$','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_ytd]		=	Replace([upsell_ytd],'$','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_to_pace]		=	Replace([upsell_to_pace],'$','')
   update  Imports.staging.WeeklyMetrics				      set [YTD_Upsell_URPO]		=	Replace([YTD_Upsell_URPO],'$','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_URPO]		=	Replace([upsell_URPO],'$','')
   update  Imports.staging.WeeklyMetrics				      set [US_Upsell]		=	Replace([US_Upsell],'$','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Upsell]		=	Replace([UK_Upsell],'$','')
   update  Imports.staging.WeeklyMetrics				      set [AU_upsell]		=	Replace([AU_upsell],'$','')
   update  Imports.staging.WeeklyMetrics				      set [(DAX)_URPO_Orders]		=	Replace([(DAX)_URPO_Orders],'$','')

   
	update  Imports.staging.WeeklyMetrics					 set [Week]	=		Replace([Week],'%','')
     update  Imports.staging.WeeklyMetrics					set [Month]	=		Replace([Month],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Year]	=		Replace([Year],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Date]	=		Replace([Date],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_OfferedIncoming_Calls]	=		Replace([Calls_OfferedIncoming_Calls],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_Sales]	=		Replace([Calls_Offered_Sales],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_Service]	=		Replace([Calls_Offered_Service],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_UK]	=		Replace([Calls_Offered_UK],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_AU]	=		Replace([Calls_Offered_AU],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Calls_Offered]=			Replace([Global_Calls_Offered],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_HandledIncoming_Calls]	=		Replace([Calls_HandledIncoming_Calls],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_Sales]	=		Replace([Calls_Handled_Sales],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_Service]	=		Replace([Calls_Handled_Service],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_UK]	=		Replace([Calls_Handled_UK],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_AU]	=		Replace([Calls_Handled_AU],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Calls_Handled]	=		Replace([Global_Calls_Handled],'%','')
   update  Imports.staging.WeeklyMetrics				      set [US_Abns]			=Replace([US_Abns],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_Calls_Abandons]			=Replace([Sales_Calls_Abandons],'%','')
   update  Imports.staging.WeeklyMetrics				      set [_]	=		Replace([_],'%','')
   update  Imports.staging.WeeklyMetrics				      set [__]	=		Replace([__],'%','')
   update  Imports.staging.WeeklyMetrics				  set [Sales_Abns] 		=	Replace([Sales_Abns],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Service_Abns]		=	Replace([Service_Abns],'%','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Abns]		=	Replace([UK_Abns],'%','')
   update  Imports.staging.WeeklyMetrics				      set [AU_Abns]		=	Replace([AU_Abns],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Abns]		=	Replace([Global_Abns],'%','')
   update  Imports.staging.WeeklyMetrics				      set [US_SL]		=	Replace([US_SL],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_SL]		=	Replace([Sales_SL],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Service_SL]		=	Replace([Service_SL],'%','')
   update  Imports.staging.WeeklyMetrics				      set [UK_SL]		=	Replace([UK_SL],'%','')
   update  Imports.staging.WeeklyMetrics				      set [AU_SL]		=	Replace([AU_SL],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Occupancy_All]		=	Replace([Occupancy_All],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Utilization]		=	Replace([Utilization],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_AHT]		=	Replace([Sales_AHT],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_Talk_Time]		=	Replace([Sales_Talk_Time],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Sales_ACW_Time]		=	Replace([Sales_ACW_Time],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Service_AHT]		=	Replace([Service_AHT],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Service_ACD]		=	Replace([Service_ACD],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Service_ACW]		=	Replace([Service_ACW],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Verascape]		=	Replace([Verascape],'%','')
   update  Imports.staging.WeeklyMetrics				      set [VOC]		=	Replace([VOC],'%','')
   update  Imports.staging.WeeklyMetrics				      set [US_Phone_to_All_Ratio]		=	Replace([US_Phone_to_All_Ratio],'%','')
   update  Imports.staging.WeeklyMetrics				      set [US_Calls_to_Orders]		=	Replace([US_Calls_to_Orders],'%','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Calls_to_Orders]		=	Replace([UK_Calls_to_Orders],'%','')
   update  Imports.staging.WeeklyMetrics				      set [AUS_Calls_to_Orders]		=	Replace([AUS_Calls_to_Orders],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Call_Center_Sales]		=	Replace([Call_Center_Sales],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Upsell_Conversion]		=	Replace([Upsell_Conversion],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Upsell_Revenue_per_Call]		=	Replace([Upsell_Revenue_per_Call],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Mail_]		=	Replace([Global_Mail_],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Email]		=	Replace([Email],'%','')
   update  Imports.staging.WeeklyMetrics				      set [(URPO)]		=	Replace([(URPO)],'%','')
   update  Imports.staging.WeeklyMetrics				      set [global_phone_orders]		=	Replace([global_phone_orders],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_AHT]		=	Replace([Global_AHT],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_AHT_(sec)]		=	Replace([Global_AHT_(sec)],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACD]		=	Replace([Global_ACD],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACD_(sec)]		=	Replace([Global_ACD_(sec)],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACW]		=	Replace([Global_ACW],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_ACW_(sec)]		=	Replace([Global_ACW_(sec)],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Avail]		=	Replace([Global_Avail],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Avail_(sec)]		=	Replace([Global_Avail_(sec)],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Staffed]		=	Replace([Global_Staffed],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Global_Staffed_(sec)]		=	Replace([Global_Staffed_(sec)],'%','')
   update  Imports.staging.WeeklyMetrics				      set [UK_AHT]		=	Replace([UK_AHT],'%','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Talk_Time]		=	Replace([UK_Talk_Time],'%','')
   update  Imports.staging.WeeklyMetrics				      set [UK_ACW_Time]		=	Replace([UK_ACW_Time],'%','')
   update  Imports.staging.WeeklyMetrics				      set [AU_AHT]		=	Replace([AU_AHT],'%','')
   update  Imports.staging.WeeklyMetrics				      set [AU_Talk_Time]		=	Replace([AU_Talk_Time],'%','')
   update  Imports.staging.WeeklyMetrics				      set [AU_ACW_Time]		=	Replace([AU_ACW_Time],'%','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_AHT]		=	Replace([TGC+_AHT],'%','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_Talk_Time]		=	Replace([TGC+_Talk_Time],'%','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_ACW_Time]		=	Replace([TGC+_ACW_Time],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Offered_TGC+]		=	Replace([Calls_Offered_TGC+],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Calls_Handled_TGC+]		=	Replace([Calls_Handled_TGC+],'%','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_SL]		=	Replace([TGC+_SL],'%','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_Abns]		=	Replace([TGC+_Abns],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Aftercall_Survey]		=	Replace([Aftercall_Survey],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Aftercall_Survey_4-wk_rolling]		=	Replace([Aftercall_Survey_4-wk_rolling],'%','')
   update  Imports.staging.WeeklyMetrics				      set [WFM_RSQ]		=	Replace([WFM_RSQ],'%','')
   update  Imports.staging.WeeklyMetrics				      set [WFM_MAPE]		=	Replace([WFM_MAPE],'%','')
   update  Imports.staging.WeeklyMetrics				      set [WFM_F A]		=	Replace([WFM_F A],'%','')
   update  Imports.staging.WeeklyMetrics				      set [ACS_by_rep]		=	Replace([ACS_by_rep],'%','')
   update  Imports.staging.WeeklyMetrics				      set [calls_to_orders]		=	Replace([calls_to_orders],'%','')
   update  Imports.staging.WeeklyMetrics				      set [TGC+_Email]		=	Replace([TGC+_Email],'%','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_CPC]		=	Replace([BSC_-_CPC],'%','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_SL]		=	Replace([BSC_-_SL],'%','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_AHT]		=	Replace([BSC_-_AHT],'%','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_Cust_Sat]		=	Replace([BSC_-_Cust_Sat],'%','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_-_score_CPC]		=	Replace([BSC_-_score_CPC],'%','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_score_-_SL]		=	Replace([BSC_score_-_SL],'%','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_score_-_AHT]		=	Replace([BSC_score_-_AHT],'%','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_score_-_Cust_Sat]		=	Replace([BSC_score_-_Cust_Sat],'%','')
   update  Imports.staging.WeeklyMetrics				      set [BSC_Weekly]		=	Replace([BSC_Weekly],'%','')
   update  Imports.staging.WeeklyMetrics				      set [Cost_Per_Call]		=	Replace([Cost_Per_Call],'%','')
   update  Imports.staging.WeeklyMetrics				      set [AHT_Premise]		=	Replace([AHT_Premise],'%','')
   update  Imports.staging.WeeklyMetrics				      set [URPO_Premise]		=	Replace([URPO_Premise],'%','')
   update  Imports.staging.WeeklyMetrics				      set [AHT_ABC]		=	Replace([AHT_ABC],'%','')
   update  Imports.staging.WeeklyMetrics				      set [URPO_ABC]		=	Replace([URPO_ABC],'%','')
   update  Imports.staging.WeeklyMetrics				      set [AHT_D]		=	Replace([AHT_D],'%','')
   update  Imports.staging.WeeklyMetrics				      set [URPO_D]		=	Replace([URPO_D],'%','')
   update  Imports.staging.WeeklyMetrics				      set [avg_ahtd]		=	Replace([avg_ahtd],'%','')
   update  Imports.staging.WeeklyMetrics				      set [avg_urpod]		=	Replace([avg_urpod],'%','')
   update  Imports.staging.WeeklyMetrics				      set [UPOM]		=	Replace([UPOM],'%','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_v_2016]		=	Replace([upsell_v_2016],'%','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_ytd]		=	Replace([upsell_ytd],'%','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_to_pace]		=	Replace([upsell_to_pace],'%','')
   update  Imports.staging.WeeklyMetrics				      set [YTD_Upsell_URPO]		=	Replace([YTD_Upsell_URPO],'%','')
   update  Imports.staging.WeeklyMetrics				      set [upsell_URPO]		=	Replace([upsell_URPO],'%','')
   update  Imports.staging.WeeklyMetrics				      set [US_Upsell]		=	Replace([US_Upsell],'%','')
   update  Imports.staging.WeeklyMetrics				      set [UK_Upsell]		=	Replace([UK_Upsell],'%','')
   update  Imports.staging.WeeklyMetrics				      set [AU_upsell]		=	Replace([AU_upsell],'%','')
   update  Imports.staging.WeeklyMetrics				      set [(DAX)_URPO_Orders]		=	Replace([(DAX)_URPO_Orders],'%','')




   select 
CAST ([Week] as Int) as Week,
CAST([Month] AS INT) as Month,
CAST([Year] AS INT) as Year,
CAST([Date] AS DATE) as Date,
CAST([Calls_OfferedIncoming_Calls] AS INT) as [Calls_OfferedIncoming_Calls] ,
CAST([Calls_Offered_Sales] AS INT) as [Calls_Offered_Sales] ,
CAST([Calls_Offered_Service] AS INT) as [Calls_Offered_Service],
CAST([Calls_Offered_UK] AS INT) as [Calls_Offered_UK] ,
CAST([Calls_Offered_AU] AS INT) as [Calls_Offered_AU] ,
CAST([Global_Calls_Offered] AS INT) as [Global_Calls_Offered],
CAST([Calls_HandledIncoming_Calls] AS INT)  as [Calls_HandledIncoming_Calls] ,
CAST([Calls_Handled_Sales] AS INT) as [Calls_Handled_Sales] ,
CAST([Calls_Handled_Service] AS INT) as [Calls_Handled_Service],
CAST([Calls_Handled_UK] AS INT)/100 as [Calls_Handled_UK] ,
CAST([Calls_Handled_AU] AS INT) [Calls_Handled_AU] ,
CAST([Global_Calls_Handled] AS INT) [Global_Calls_Handled] ,
CAST([US_Abns] AS INT)  [US_Abns] ,
CAST([Sales_Calls_Abandons]  as  DECIMAL) as [Sales_Calls_Abandons],
CAST([_]  as  DECIMAL) as Blank1,
CAST([__]  as  DECIMAL(18, 4))/100 as Blank ,
CAST([Sales_Abns]  as  DECIMAL(18, 4))/100  as [Sales_Abns],
CAST([Service_Abns]  as  DECIMAL(18, 4))/100  as [Service_Abns] ,
CAST([UK_Abns]  as  DECIMAL(18, 4))/100  as [UK_Abns] ,
CAST([AU_Abns]  as  DECIMAL(18, 4))/100  as [AU_Abns] ,
CAST([Global_Abns] AS INT) as [Global_Abns],
CAST([US_SL]  as  DECIMAL(18, 4))/100  [US_SL] ,
CAST([Sales_SL] As  DECIMAL(18, 4))/100 [Sales_SL]  ,
CAST([Service_SL] As  DECIMAL(18, 4))/100 [Service_SL]  ,
CAST([UK_SL] As  DECIMAL(18, 4))/100 [UK_SL] ,
CAST([AU_SL]  As  DECIMAL(18, 4))/100  [AU_SL] ,
CAST([Occupancy_All]  As  DECIMAL(18, 4))/100  [Occupancy_All] ,
CAST([Utilization]  As  DECIMAL(18, 4))/100 [Utilization] ,
CAST([Sales_AHT] AS TIME) [Sales_AHT] ,
CAST([Sales_Talk_Time] AS TIME) [Sales_Talk_Time] ,
CAST([Sales_ACW_Time] AS TIME) [Sales_ACW_Time] ,
CAST([Service_AHT] AS TIME) [Service_AHT],
CAST([Service_ACD] AS TIME)[Service_ACD] ,
CAST([Service_ACW] AS TIME) [Service_ACW],
CAST([Verascape] AS decimal) [Verascape],
CAST([VOC] AS MONEY) [VOC] ,
CAST([US_Phone_to_All_Ratio]   As  DECIMAL(18, 4))/100  [US_Phone_to_All_Ratio] ,
CAST([US_Calls_to_Orders]  As  DECIMAL(18, 4))/100  [US_Calls_to_Orders] ,
CAST([UK_Calls_to_Orders]  As  DECIMAL(18, 4))/100  [UK_Calls_to_Orders],
CAST([AUS_Calls_to_Orders]  As  DECIMAL(18, 4))/100 [AUS_Calls_to_Orders] ,
CAST([Call_Center_Sales] AS MONEY) [Call_Center_Sales],
CAST([Upsell_Conversion]  As  DECIMAL(18, 4))/100  [Upsell_Conversion] ,
CAST([Upsell_Revenue_per_Call] AS MONEY) [Upsell_Revenue_per_Call],
CAST([Global_Mail_] AS INT) Global_Mail,
CAST([Email] AS INT) as Email,
CAST([(URPO)]  As  DECIMAL(18, 4)) URPO ,
CAST([global_phone_orders] AS INT) [global_phone_orders],
CAST([Global_AHT] AS TIME) [Global_AHT],
CAST([Global_AHT_(sec)] AS INT) Global_AHT_sec,
CAST([Global_ACD] AS TIME) [Global_ACD],
CAST([Global_ACD_(sec)] AS INT) Global_ACD_sec,
CAST([Global_ACW] AS TIME) [Global_ACW] ,
CAST([Global_ACW_(sec)] AS INT) Global_ACW_sec,
[Global_Avail] ,
CAST([Global_Avail_(sec)] AS INT) global_Avail_sec,
[Global_Staffed],
CAST([Global_Staffed_(sec)] AS INT) Global_Staffed_sec,
CAST([UK_AHT]  AS TIME) [UK_AHT] ,
CAST([UK_Talk_Time]  AS TIME) [UK_Talk_Time] ,
CAST([UK_ACW_Time]  AS TIME) [UK_ACW_Time] ,
CAST([AU_AHT]  AS TIME) [AU_AHT],
CAST([AU_Talk_Time]  AS TIME) [AU_Talk_Time] ,
CAST([AU_ACW_Time]  AS TIME) [AU_ACW_Time],
CAST([TGC+_AHT] AS TIME) [TGC+AHT] ,
CAST([TGC+_Talk_Time]  AS TIME) [TGC+Talk_Time] ,
CAST([TGC+_ACW_Time]  AS TIME) [TGC+_ACW_Time],
CAST([Calls_Offered_TGC+] AS INT) [Calls_Offered_TGC+] ,
CAST([Calls_Handled_TGC+] AS INT) [Calls_Handled_TGC+] ,
CAST([TGC+_SL]  As  DECIMAL(18, 4))/100 [TGC+_SL] ,
CAST([TGC+_Abns]  As  DECIMAL(18, 4))/100 [TGC+_Abns] ,
CAST([Aftercall_Survey]  As  DECIMAL(18, 4))/100 [Aftercall_Survey] ,
CAST([Aftercall_Survey_4-wk_rolling]  As  DECIMAL(18, 4))/100 [Aftercall_Survey_4wk_rolling] ,
CAST([WFM_RSQ]  As  DECIMAL(18, 4))/100 [WFM_RSQ] ,
CAST([WFM_MAPE]  As  DECIMAL(18, 4))/100 [WFM_MAPE],
CAST([WFM_F A]  As  DECIMAL(18, 4))/100 AS WFM_F_A,
CAST([ACS_by_rep]  As  DECIMAL(18, 4))/100 [ACS_by_rep],
CAST([calls_to_orders]  As  DECIMAL(18, 4))/100 [calls_to_orders],
CAST([TGC+_Email] AS INT) [TGC+_Email] ,
CAST([BSC_-_CPC] AS MONEY) [BSC_CPC],
CAST([BSC_-_SL]  As  DECIMAL(18, 4))/100 [BSC_SL] ,
CAST([BSC_-_AHT] AS TIME) [BSC_AHT],
CAST([BSC_-_Cust_Sat]  As  DECIMAL(18, 4))/100 [BSC_Cust_Sat],
CAST([BSC_-_score_CPC]  As  DECIMAL(18, 4))/100 [BSC_score_CPC],
CAST([BSC_score_-_SL]  As  DECIMAL(18, 4))/100 [BSC_score_SL] ,
CAST([BSC_score_-_AHT]  As  DECIMAL(18, 4))/100 [BSC_score_AHT],
CAST([BSC_score_-_Cust_Sat]  As  DECIMAL(18, 4))/100 [BSC_score_Cust_Sat],
CAST([BSC_Weekly]  As  DECIMAL(18, 4))/100 [BSC_Weekly] ,
CAST([Cost_Per_Call] AS MONEY) [Cost_Per_Call] ,
CAST([AHT_Premise] AS TIME) [AHT_Premise] ,
CAST([URPO_Premise] AS MONEY) [URPO_Premise],
CAST([AHT_ABC] AS TIME) [AHT_ABC],
CAST([URPO_ABC] AS MONEY) [URPO_ABC],
CAST([AHT_D]  As  DECIMAL(18, 4))/100 [AHT_D],
CAST([URPO_D]  As  DECIMAL(18, 4))/100 [URPO_D],
CAST([avg_ahtd]  As  DECIMAL(18, 4))/100 [avg_ahtd],
CAST([avg_urpod]  As  DECIMAL(18, 4))/100 [avg_urpod],
CAST([UPOM] AS MONEY) [UPOM],
 CONVERT(int, CONVERT(float, [upsell_v_2016]))  [upsell_v_2016],
CAST([upsell_ytd] AS MONEY) [upsell_ytd],
 CONVERT(int, CONVERT(float, [upsell_to_pace])) [upsell_to_pace] ,
CAST([YTD_Upsell_URPO] AS MONEY) [YTD_Upsell_URPO],
CAST([upsell_URPO] AS MONEY) [upsell_URPO],
CAST([US_Upsell] AS MONEY) [US_Upsell],
CAST([UK_Upsell] AS MONEY) [UK_Upsell],
CAST([AU_upsell] AS MONEY) [AU_upsell],
CAST([(DAX)_URPO_Orders] AS INT) DAX_URPO_Orders,
GETDATE() AS DMLastUpdated


into #temp3
from Imports.staging.WeeklyMetrics		



INSERT INTO Imports.CallCenter.WeeklyMetrics
select *  from #temp3


drop table #temp3




GO
