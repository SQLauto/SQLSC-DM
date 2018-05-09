SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 
 CREATE procedure [dbo].[CallCenter_AgentMetrics_Clean_Import] as 
   update Imports.staging.AgentMetrics	SET	[year]	=	Replace([year],'%','')
   update Imports.staging.AgentMetrics	SET	[half]	=	Replace([half],'%','')
   update Imports.staging.AgentMetrics	SET	[quarter]	=	Replace([quarter],'%','')
   update Imports.staging.AgentMetrics	SET	[month]	=	Replace([month],'%','')
   update Imports.staging.AgentMetrics	SET	[Week_num]	=	Replace([Week_num],'%','')
   update Imports.staging.AgentMetrics	SET	[Week_of]	=	Replace([Week_of],'%','')
   update Imports.staging.AgentMetrics	SET	[Rep]	=	Replace([Rep],'%','')
   update Imports.staging.AgentMetrics	SET	[Rep_ID]	=	Replace([Rep_ID],'%','')
   update Imports.staging.AgentMetrics	SET	[Rep_ID4]	=	Replace([Rep_ID4],'%','')
   update Imports.staging.AgentMetrics	SET	[Sup]	=	Replace([Sup],'%','')
   update Imports.staging.AgentMetrics	SET	[DAX_ID]	=	Replace([DAX_ID],'%','')
   update Imports.staging.AgentMetrics	SET	[ACD_Calls]	=	Replace([ACD_Calls],'%','')
   update Imports.staging.AgentMetrics	SET	[ACD]	=	Replace([ACD],'%','')
   update Imports.staging.AgentMetrics	SET	[ACW]	=	Replace([ACW],'%','')
   update Imports.staging.AgentMetrics	SET	[AHT]	=	Replace([AHT],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX]	=	Replace([AUX],'%','')
   update Imports.staging.AgentMetrics	SET	[Adherence]	=	Replace([Adherence],'%','')
   update Imports.staging.AgentMetrics	SET	[AHT_AVG]	=	Replace([AHT_AVG],'%','')
   update Imports.staging.AgentMetrics	SET	[AHT_SDEV]	=	Replace([AHT_SDEV],'%','')
   update Imports.staging.AgentMetrics	SET	[AHT_UCL]	=	Replace([AHT_UCL],'%','')
   update Imports.staging.AgentMetrics	SET	[AHT_LCL]	=	Replace([AHT_LCL],'%','')
   update Imports.staging.AgentMetrics	SET	[C2C_AVG]	=	Replace([C2C_AVG],'%','')
   update Imports.staging.AgentMetrics	SET	[C2C_SDEV]	=	Replace([C2C_SDEV],'%','')
   update Imports.staging.AgentMetrics	SET	[C2C_UCL]	=	Replace([C2C_UCL],'%','')
   update Imports.staging.AgentMetrics	SET	[C2C_LCL]	=	Replace([C2C_LCL],'%','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_Orders]	=	Replace([Cross0Sell_Orders],'%','')
   update Imports.staging.AgentMetrics	SET	[Total_Orders]	=	Replace([Total_Orders],'%','')
   update Imports.staging.AgentMetrics	SET	[Conversion_%]	=	Replace([Conversion_%],'%','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_USD]	=	Replace([Cross0Sell_USD],'%','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_GBP]	=	Replace([Cross0Sell_GBP],'%','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_AUD]	=	Replace([Cross0Sell_AUD],'%','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_$]	=	Replace([Cross0Sell_$],'%','')
   update Imports.staging.AgentMetrics	SET	[URPO]	=	Replace([URPO],'%','')
   update Imports.staging.AgentMetrics	SET	[UPC]	=	Replace([UPC],'%','')
   update Imports.staging.AgentMetrics	SET	[UPOM]	=	Replace([UPOM],'%','')
   update Imports.staging.AgentMetrics	SET	[URPO_AVG]	=	Replace([URPO_AVG],'%','')
   update Imports.staging.AgentMetrics	SET	[UPC_AVG]	=	Replace([UPC_AVG],'%','')
   update Imports.staging.AgentMetrics	SET	[UPOM_AVG]	=	Replace([UPOM_AVG],'%','')
   update Imports.staging.AgentMetrics	SET	[Errors]	=	Replace([Errors],'%','')
   update Imports.staging.AgentMetrics	SET	[Week_of_Filter]	=	Replace([Week_of_Filter],'%','')
   update Imports.staging.AgentMetrics	SET	[Torch_Team]	=	Replace([Torch_Team],'%','')
   update Imports.staging.AgentMetrics	SET	[Avg_Non0Call_ACW]	=	Replace([Avg_Non0Call_ACW],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX_%]	=	Replace([AUX_%],'%','')
   update Imports.staging.AgentMetrics	SET	[ACW_%]	=	Replace([ACW_%],'%','')
   update Imports.staging.AgentMetrics	SET	[ACD_(sec)]	=	Replace([ACD_(sec)],'%','')
   update Imports.staging.AgentMetrics	SET	[ACW_(sec)]	=	Replace([ACW_(sec)],'%','')
   update Imports.staging.AgentMetrics	SET	[NC0ACW_(sec)]	=	Replace([NC0ACW_(sec)],'%','')
   update Imports.staging.AgentMetrics	SET	[AHT_(sec)]	=	Replace([AHT_(sec)],'%','')
   update Imports.staging.AgentMetrics	SET	[Accuracy]	=	Replace([Accuracy],'%','')
   update Imports.staging.AgentMetrics	SET	[ACS]	=	Replace([ACS],'%','')
   update Imports.staging.AgentMetrics	SET	[Office]	=	Replace([Office],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX_0]	=	Replace([AUX_0],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX_1]	=	Replace([AUX_1],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX_3]	=	Replace([AUX_3],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX_RONA]	=	Replace([AUX_RONA],'%','')
   update Imports.staging.AgentMetrics	SET	[ACW_%_avg]	=	Replace([ACW_%_avg],'%','')
   update Imports.staging.AgentMetrics	SET	[ISP]	=	Replace([ISP],'%','')
   update Imports.staging.AgentMetrics	SET	[Staffed_Time]	=	Replace([Staffed_Time],'%','')
   update Imports.staging.AgentMetrics	SET	[Hours]	=	Replace([Hours],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX_total_sec]	=	Replace([AUX_total_sec],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX_0_sec]	=	Replace([AUX_0_sec],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX_1_sec]	=	Replace([AUX_1_sec],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX_3_sec]	=	Replace([AUX_3_sec],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX_RONA_sec]	=	Replace([AUX_RONA_sec],'%','')
   update Imports.staging.AgentMetrics	SET	[Staffed_Time_sec]	=	Replace([Staffed_Time_sec],'%','')
   update Imports.staging.AgentMetrics	SET	[AUX1s]	=	Replace([AUX1s],'%','')
   update Imports.staging.AgentMetrics	SET	[ACWs]	=	Replace([ACWs],'%','')
   update Imports.staging.AgentMetrics	SET	[CC_%]	=	Replace([CC_%],'%','')
   update Imports.staging.AgentMetrics	SET	[CC_#]	=	Replace([CC_#],'%','')
   update Imports.staging.AgentMetrics	SET	[CC_score]	=	Replace([CC_score],'%','')
   update Imports.staging.AgentMetrics	SET	[CC_max]	=	Replace([CC_max],'%','')
   update Imports.staging.AgentMetrics	SET	[ACS_%]	=	Replace([ACS_%],'%','')
   update Imports.staging.AgentMetrics	SET	[ACS_#]	=	Replace([ACS_#],'%','')
   update Imports.staging.AgentMetrics	SET	[ACS_score]	=	Replace([ACS_score],'%','')
   update Imports.staging.AgentMetrics	SET	[ACS_max]	=	Replace([ACS_max],'%','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACS]	=	Replace([BSC_ACS],'%','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACC]	=	Replace([BSC_ACC],'%','')
   update Imports.staging.AgentMetrics	SET	[BSC_C2C]	=	Replace([BSC_C2C],'%','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACW]	=	Replace([BSC_ACW],'%','')
   update Imports.staging.AgentMetrics	SET	[BSC_UPOM]	=	Replace([BSC_UPOM],'%','')
   update Imports.staging.AgentMetrics	SET	[BSC_CC]	=	Replace([BSC_CC],'%','')
   update Imports.staging.AgentMetrics	SET	[BSC_AHT]	=	Replace([BSC_AHT],'%','')
   update Imports.staging.AgentMetrics	SET	[BSC]	=	Replace([BSC],'%','')
   update Imports.staging.AgentMetrics	SET	[AHT_Rep]	=	Replace([AHT_Rep],'%','')




      update Imports.staging.AgentMetrics	SET	[year]	=	Replace([year],',','')
   update Imports.staging.AgentMetrics	SET	[half]	=	Replace([half],',','')
   update Imports.staging.AgentMetrics	SET	[quarter]	=	Replace([quarter],',','')
   update Imports.staging.AgentMetrics	SET	[month]	=	Replace([month],',','')
   update Imports.staging.AgentMetrics	SET	[Week_num]	=	Replace([Week_num],',','')
   update Imports.staging.AgentMetrics	SET	[Week_of]	=	Replace([Week_of],',','')
   update Imports.staging.AgentMetrics	SET	[Rep]	=	Replace([Rep],',','')
   update Imports.staging.AgentMetrics	SET	[Rep_ID]	=	Replace([Rep_ID],',','')
   update Imports.staging.AgentMetrics	SET	[Rep_ID4]	=	Replace([Rep_ID4],',','')
   update Imports.staging.AgentMetrics	SET	[Sup]	=	Replace([Sup],',','')
   update Imports.staging.AgentMetrics	SET	[DAX_ID]	=	Replace([DAX_ID],',','')
   update Imports.staging.AgentMetrics	SET	[ACD_Calls]	=	Replace([ACD_Calls],',','')
   update Imports.staging.AgentMetrics	SET	[ACD]	=	Replace([ACD],',','')
   update Imports.staging.AgentMetrics	SET	[ACW]	=	Replace([ACW],',','')
   update Imports.staging.AgentMetrics	SET	[AHT]	=	Replace([AHT],',','')
   update Imports.staging.AgentMetrics	SET	[AUX]	=	Replace([AUX],',','')
   update Imports.staging.AgentMetrics	SET	[Adherence]	=	Replace([Adherence],',','')
   update Imports.staging.AgentMetrics	SET	[AHT_AVG]	=	Replace([AHT_AVG],',','')
   update Imports.staging.AgentMetrics	SET	[AHT_SDEV]	=	Replace([AHT_SDEV],',','')
   update Imports.staging.AgentMetrics	SET	[AHT_UCL]	=	Replace([AHT_UCL],',','')
   update Imports.staging.AgentMetrics	SET	[AHT_LCL]	=	Replace([AHT_LCL],',','')
   update Imports.staging.AgentMetrics	SET	[C2C_AVG]	=	Replace([C2C_AVG],',','')
   update Imports.staging.AgentMetrics	SET	[C2C_SDEV]	=	Replace([C2C_SDEV],',','')
   update Imports.staging.AgentMetrics	SET	[C2C_UCL]	=	Replace([C2C_UCL],',','')
   update Imports.staging.AgentMetrics	SET	[C2C_LCL]	=	Replace([C2C_LCL],',','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_Orders]	=	Replace([Cross0Sell_Orders],',','')
   update Imports.staging.AgentMetrics	SET	[Total_Orders]	=	Replace([Total_Orders],',','')
   update Imports.staging.AgentMetrics	SET	[Conversion_%]	=	Replace([Conversion_%],',','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_USD]	=	Replace([Cross0Sell_USD],',','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_GBP]	=	Replace([Cross0Sell_GBP],',','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_AUD]	=	Replace([Cross0Sell_AUD],',','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_$]	=	Replace([Cross0Sell_$],',','')
   update Imports.staging.AgentMetrics	SET	[URPO]	=	Replace([URPO],',','')
   update Imports.staging.AgentMetrics	SET	[UPC]	=	Replace([UPC],',','')
   update Imports.staging.AgentMetrics	SET	[UPOM]	=	Replace([UPOM],',','')
   update Imports.staging.AgentMetrics	SET	[URPO_AVG]	=	Replace([URPO_AVG],',','')
   update Imports.staging.AgentMetrics	SET	[UPC_AVG]	=	Replace([UPC_AVG],',','')
   update Imports.staging.AgentMetrics	SET	[UPOM_AVG]	=	Replace([UPOM_AVG],',','')
   update Imports.staging.AgentMetrics	SET	[Errors]	=	Replace([Errors],',','')
   update Imports.staging.AgentMetrics	SET	[Week_of_Filter]	=	Replace([Week_of_Filter],',','')
   update Imports.staging.AgentMetrics	SET	[Torch_Team]	=	Replace([Torch_Team],',','')
   update Imports.staging.AgentMetrics	SET	[Avg_Non0Call_ACW]	=	Replace([Avg_Non0Call_ACW],',','')
   update Imports.staging.AgentMetrics	SET	[AUX_%]	=	Replace([AUX_%],',','')
   update Imports.staging.AgentMetrics	SET	[ACW_%]	=	Replace([ACW_%],',','')
   update Imports.staging.AgentMetrics	SET	[ACD_(sec)]	=	Replace([ACD_(sec)],',','')
   update Imports.staging.AgentMetrics	SET	[ACW_(sec)]	=	Replace([ACW_(sec)],',','')
   update Imports.staging.AgentMetrics	SET	[NC0ACW_(sec)]	=	Replace([NC0ACW_(sec)],',','')
   update Imports.staging.AgentMetrics	SET	[AHT_(sec)]	=	Replace([AHT_(sec)],',','')
   update Imports.staging.AgentMetrics	SET	[Accuracy]	=	Replace([Accuracy],',','')
   update Imports.staging.AgentMetrics	SET	[ACS]	=	Replace([ACS],',','')
   update Imports.staging.AgentMetrics	SET	[Office]	=	Replace([Office],',','')
   update Imports.staging.AgentMetrics	SET	[AUX_0]	=	Replace([AUX_0],',','')
   update Imports.staging.AgentMetrics	SET	[AUX_1]	=	Replace([AUX_1],',','')
   update Imports.staging.AgentMetrics	SET	[AUX_3]	=	Replace([AUX_3],',','')
   update Imports.staging.AgentMetrics	SET	[AUX_RONA]	=	Replace([AUX_RONA],',','')
   update Imports.staging.AgentMetrics	SET	[ACW_%_avg]	=	Replace([ACW_%_avg],',','')
   update Imports.staging.AgentMetrics	SET	[ISP]	=	Replace([ISP],',','')
   update Imports.staging.AgentMetrics	SET	[Staffed_Time]	=	Replace([Staffed_Time],',','')
   update Imports.staging.AgentMetrics	SET	[Hours]	=	Replace([Hours],',','')
   update Imports.staging.AgentMetrics	SET	[AUX_total_sec]	=	Replace([AUX_total_sec],',','')
   update Imports.staging.AgentMetrics	SET	[AUX_0_sec]	=	Replace([AUX_0_sec],',','')
   update Imports.staging.AgentMetrics	SET	[AUX_1_sec]	=	Replace([AUX_1_sec],',','')
   update Imports.staging.AgentMetrics	SET	[AUX_3_sec]	=	Replace([AUX_3_sec],',','')
   update Imports.staging.AgentMetrics	SET	[AUX_RONA_sec]	=	Replace([AUX_RONA_sec],',','')
   update Imports.staging.AgentMetrics	SET	[Staffed_Time_sec]	=	Replace([Staffed_Time_sec],',','')
   update Imports.staging.AgentMetrics	SET	[AUX1s]	=	Replace([AUX1s],',','')
   update Imports.staging.AgentMetrics	SET	[ACWs]	=	Replace([ACWs],',','')
   update Imports.staging.AgentMetrics	SET	[CC_%]	=	Replace([CC_%],',','')
   update Imports.staging.AgentMetrics	SET	[CC_#]	=	Replace([CC_#],',','')
   update Imports.staging.AgentMetrics	SET	[CC_score]	=	Replace([CC_score],',','')
   update Imports.staging.AgentMetrics	SET	[CC_max]	=	Replace([CC_max],',','')
   update Imports.staging.AgentMetrics	SET	[ACS_%]	=	Replace([ACS_%],',','')
   update Imports.staging.AgentMetrics	SET	[ACS_#]	=	Replace([ACS_#],',','')
   update Imports.staging.AgentMetrics	SET	[ACS_score]	=	Replace([ACS_score],',','')
   update Imports.staging.AgentMetrics	SET	[ACS_max]	=	Replace([ACS_max],',','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACS]	=	Replace([BSC_ACS],',','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACC]	=	Replace([BSC_ACC],',','')
   update Imports.staging.AgentMetrics	SET	[BSC_C2C]	=	Replace([BSC_C2C],',','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACW]	=	Replace([BSC_ACW],',','')
   update Imports.staging.AgentMetrics	SET	[BSC_UPOM]	=	Replace([BSC_UPOM],',','')
   update Imports.staging.AgentMetrics	SET	[BSC_CC]	=	Replace([BSC_CC],',','')
   update Imports.staging.AgentMetrics	SET	[BSC_AHT]	=	Replace([BSC_AHT],',','')
   update Imports.staging.AgentMetrics	SET	[BSC]	=	Replace([BSC],',','')
   update Imports.staging.AgentMetrics	SET	[AHT_Rep]	=	Replace([AHT_Rep],',','')


   
   update Imports.staging.AgentMetrics	SET	[year]	=	Replace([year],'$','')
   update Imports.staging.AgentMetrics	SET	[half]	=	Replace([half],'$','')
   update Imports.staging.AgentMetrics	SET	[quarter]	=	Replace([quarter],'$','')
   update Imports.staging.AgentMetrics	SET	[month]	=	Replace([month],'$','')
   update Imports.staging.AgentMetrics	SET	[Week_num]	=	Replace([Week_num],'$','')
   update Imports.staging.AgentMetrics	SET	[Week_of]	=	Replace([Week_of],'$','')
   update Imports.staging.AgentMetrics	SET	[Rep]	=	Replace([Rep],'$','')
   update Imports.staging.AgentMetrics	SET	[Rep_ID]	=	Replace([Rep_ID],'$','')
   update Imports.staging.AgentMetrics	SET	[Rep_ID4]	=	Replace([Rep_ID4],'$','')
   update Imports.staging.AgentMetrics	SET	[Sup]	=	Replace([Sup],'$','')
   update Imports.staging.AgentMetrics	SET	[DAX_ID]	=	Replace([DAX_ID],'$','')
   update Imports.staging.AgentMetrics	SET	[ACD_Calls]	=	Replace([ACD_Calls],'$','')
   update Imports.staging.AgentMetrics	SET	[ACD]	=	Replace([ACD],'$','')
   update Imports.staging.AgentMetrics	SET	[ACW]	=	Replace([ACW],'$','')
   update Imports.staging.AgentMetrics	SET	[AHT]	=	Replace([AHT],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX]	=	Replace([AUX],'$','')
   update Imports.staging.AgentMetrics	SET	[Adherence]	=	Replace([Adherence],'$','')
   update Imports.staging.AgentMetrics	SET	[AHT_AVG]	=	Replace([AHT_AVG],'$','')
   update Imports.staging.AgentMetrics	SET	[AHT_SDEV]	=	Replace([AHT_SDEV],'$','')
   update Imports.staging.AgentMetrics	SET	[AHT_UCL]	=	Replace([AHT_UCL],'$','')
   update Imports.staging.AgentMetrics	SET	[AHT_LCL]	=	Replace([AHT_LCL],'$','')
   update Imports.staging.AgentMetrics	SET	[C2C_AVG]	=	Replace([C2C_AVG],'$','')
   update Imports.staging.AgentMetrics	SET	[C2C_SDEV]	=	Replace([C2C_SDEV],'$','')
   update Imports.staging.AgentMetrics	SET	[C2C_UCL]	=	Replace([C2C_UCL],'$','')
   update Imports.staging.AgentMetrics	SET	[C2C_LCL]	=	Replace([C2C_LCL],'$','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_Orders]	=	Replace([Cross0Sell_Orders],'$','')
   update Imports.staging.AgentMetrics	SET	[Total_Orders]	=	Replace([Total_Orders],'$','')
   update Imports.staging.AgentMetrics	SET	[Conversion_%]	=	Replace([Conversion_%],'$','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_USD]	=	Replace([Cross0Sell_USD],'$','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_GBP]	=	Replace([Cross0Sell_GBP],'$','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_AUD]	=	Replace([Cross0Sell_AUD],'$','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_$]	=	Replace([Cross0Sell_$],'$','')
   update Imports.staging.AgentMetrics	SET	[URPO]	=	Replace([URPO],'$','')
   update Imports.staging.AgentMetrics	SET	[UPC]	=	Replace([UPC],'$','')
   update Imports.staging.AgentMetrics	SET	[UPOM]	=	Replace([UPOM],'$','')
   update Imports.staging.AgentMetrics	SET	[URPO_AVG]	=	Replace([URPO_AVG],'$','')
   update Imports.staging.AgentMetrics	SET	[UPC_AVG]	=	Replace([UPC_AVG],'$','')
   update Imports.staging.AgentMetrics	SET	[UPOM_AVG]	=	Replace([UPOM_AVG],'$','')
   update Imports.staging.AgentMetrics	SET	[Errors]	=	Replace([Errors],'$','')
   update Imports.staging.AgentMetrics	SET	[Week_of_Filter]	=	Replace([Week_of_Filter],'$','')
   update Imports.staging.AgentMetrics	SET	[Torch_Team]	=	Replace([Torch_Team],'$','')
   update Imports.staging.AgentMetrics	SET	[Avg_Non0Call_ACW]	=	Replace([Avg_Non0Call_ACW],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX_%]	=	Replace([AUX_%],'$','')
   update Imports.staging.AgentMetrics	SET	[ACW_%]	=	Replace([ACW_%],'$','')
   update Imports.staging.AgentMetrics	SET	[ACD_(sec)]	=	Replace([ACD_(sec)],'$','')
   update Imports.staging.AgentMetrics	SET	[ACW_(sec)]	=	Replace([ACW_(sec)],'$','')
   update Imports.staging.AgentMetrics	SET	[NC0ACW_(sec)]	=	Replace([NC0ACW_(sec)],'$','')
   update Imports.staging.AgentMetrics	SET	[AHT_(sec)]	=	Replace([AHT_(sec)],'$','')
   update Imports.staging.AgentMetrics	SET	[Accuracy]	=	Replace([Accuracy],'$','')
   update Imports.staging.AgentMetrics	SET	[ACS]	=	Replace([ACS],'$','')
   update Imports.staging.AgentMetrics	SET	[Office]	=	Replace([Office],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX_0]	=	Replace([AUX_0],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX_1]	=	Replace([AUX_1],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX_3]	=	Replace([AUX_3],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX_RONA]	=	Replace([AUX_RONA],'$','')
   update Imports.staging.AgentMetrics	SET	[ACW_%_avg]	=	Replace([ACW_%_avg],'$','')
   update Imports.staging.AgentMetrics	SET	[ISP]	=	Replace([ISP],'$','')
   update Imports.staging.AgentMetrics	SET	[Staffed_Time]	=	Replace([Staffed_Time],'$','')
   update Imports.staging.AgentMetrics	SET	[Hours]	=	Replace([Hours],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX_total_sec]	=	Replace([AUX_total_sec],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX_0_sec]	=	Replace([AUX_0_sec],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX_1_sec]	=	Replace([AUX_1_sec],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX_3_sec]	=	Replace([AUX_3_sec],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX_RONA_sec]	=	Replace([AUX_RONA_sec],'$','')
   update Imports.staging.AgentMetrics	SET	[Staffed_Time_sec]	=	Replace([Staffed_Time_sec],'$','')
   update Imports.staging.AgentMetrics	SET	[AUX1s]	=	Replace([AUX1s],'$','')
   update Imports.staging.AgentMetrics	SET	[ACWs]	=	Replace([ACWs],'$','')
   update Imports.staging.AgentMetrics	SET	[CC_%]	=	Replace([CC_%],'$','')
   update Imports.staging.AgentMetrics	SET	[CC_#]	=	Replace([CC_#],'$','')
   update Imports.staging.AgentMetrics	SET	[CC_score]	=	Replace([CC_score],'$','')
   update Imports.staging.AgentMetrics	SET	[CC_max]	=	Replace([CC_max],'$','')
   update Imports.staging.AgentMetrics	SET	[ACS_%]	=	Replace([ACS_%],'$','')
   update Imports.staging.AgentMetrics	SET	[ACS_#]	=	Replace([ACS_#],'$','')
   update Imports.staging.AgentMetrics	SET	[ACS_score]	=	Replace([ACS_score],'$','')
   update Imports.staging.AgentMetrics	SET	[ACS_max]	=	Replace([ACS_max],'$','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACS]	=	Replace([BSC_ACS],'$','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACC]	=	Replace([BSC_ACC],'$','')
   update Imports.staging.AgentMetrics	SET	[BSC_C2C]	=	Replace([BSC_C2C],'$','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACW]	=	Replace([BSC_ACW],'$','')
   update Imports.staging.AgentMetrics	SET	[BSC_UPOM]	=	Replace([BSC_UPOM],'$','')
   update Imports.staging.AgentMetrics	SET	[BSC_CC]	=	Replace([BSC_CC],'$','')
   update Imports.staging.AgentMetrics	SET	[BSC_AHT]	=	Replace([BSC_AHT],'$','')
   update Imports.staging.AgentMetrics	SET	[BSC]	=	Replace([BSC],'$','')
   update Imports.staging.AgentMetrics	SET	[AHT_Rep]	=	Replace([AHT_Rep],'$','')



    update Imports.staging.AgentMetrics	SET	[year]	=	Replace([year],' ','')
   update Imports.staging.AgentMetrics	SET	[half]	=	Replace([half],' ','')
   update Imports.staging.AgentMetrics	SET	[quarter]	=	Replace([quarter],' ','')
   update Imports.staging.AgentMetrics	SET	[month]	=	Replace([month],' ','')
   update Imports.staging.AgentMetrics	SET	[Week_num]	=	Replace([Week_num],' ','')
   update Imports.staging.AgentMetrics	SET	[Week_of]	=	Replace([Week_of],' ','')
   update Imports.staging.AgentMetrics	SET	[Rep]	=	Replace([Rep],' ','')
   update Imports.staging.AgentMetrics	SET	[Rep_ID]	=	Replace([Rep_ID],' ','')
   update Imports.staging.AgentMetrics	SET	[Rep_ID4]	=	Replace([Rep_ID4],' ','')
   update Imports.staging.AgentMetrics	SET	[Sup]	=	Replace([Sup],' ','')
   update Imports.staging.AgentMetrics	SET	[DAX_ID]	=	Replace([DAX_ID],' ','')
   update Imports.staging.AgentMetrics	SET	[ACD_Calls]	=	Replace([ACD_Calls],' ','')
   update Imports.staging.AgentMetrics	SET	[ACD]	=	Replace([ACD],' ','')
   update Imports.staging.AgentMetrics	SET	[ACW]	=	Replace([ACW],' ','')
   update Imports.staging.AgentMetrics	SET	[AHT]	=	Replace([AHT],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX]	=	Replace([AUX],' ','')
   update Imports.staging.AgentMetrics	SET	[Adherence]	=	Replace([Adherence],' ','')
   update Imports.staging.AgentMetrics	SET	[AHT_AVG]	=	Replace([AHT_AVG],' ','')
   update Imports.staging.AgentMetrics	SET	[AHT_SDEV]	=	Replace([AHT_SDEV],' ','')
   update Imports.staging.AgentMetrics	SET	[AHT_UCL]	=	Replace([AHT_UCL],' ','')
   update Imports.staging.AgentMetrics	SET	[AHT_LCL]	=	Replace([AHT_LCL],' ','')
   update Imports.staging.AgentMetrics	SET	[C2C_AVG]	=	Replace([C2C_AVG],' ','')
   update Imports.staging.AgentMetrics	SET	[C2C_SDEV]	=	Replace([C2C_SDEV],' ','')
   update Imports.staging.AgentMetrics	SET	[C2C_UCL]	=	Replace([C2C_UCL],' ','')
   update Imports.staging.AgentMetrics	SET	[C2C_LCL]	=	Replace([C2C_LCL],' ','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_Orders]	=	Replace([Cross0Sell_Orders],' ','')
   update Imports.staging.AgentMetrics	SET	[Total_Orders]	=	Replace([Total_Orders],' ','')
   update Imports.staging.AgentMetrics	SET	[Conversion_%]	=	Replace([Conversion_%],' ','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_USD]	=	Replace([Cross0Sell_USD],' ','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_GBP]	=	Replace([Cross0Sell_GBP],' ','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_AUD]	=	Replace([Cross0Sell_AUD],' ','')
   update Imports.staging.AgentMetrics	SET	[Cross0Sell_$]	=	Replace([Cross0Sell_$],' ','')
   update Imports.staging.AgentMetrics	SET	[URPO]	=	Replace([URPO],' ','')
   update Imports.staging.AgentMetrics	SET	[UPC]	=	Replace([UPC],' ','')
   update Imports.staging.AgentMetrics	SET	[UPOM]	=	Replace([UPOM],' ','')
   update Imports.staging.AgentMetrics	SET	[URPO_AVG]	=	Replace([URPO_AVG],' ','')
   update Imports.staging.AgentMetrics	SET	[UPC_AVG]	=	Replace([UPC_AVG],' ','')
   update Imports.staging.AgentMetrics	SET	[UPOM_AVG]	=	Replace([UPOM_AVG],' ','')
   update Imports.staging.AgentMetrics	SET	[Errors]	=	Replace([Errors],' ','')
   update Imports.staging.AgentMetrics	SET	[Week_of_Filter]	=	Replace([Week_of_Filter],' ','')
   update Imports.staging.AgentMetrics	SET	[Torch_Team]	=	Replace([Torch_Team],' ','')
   update Imports.staging.AgentMetrics	SET	[Avg_Non0Call_ACW]	=	Replace([Avg_Non0Call_ACW],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX_%]	=	Replace([AUX_%],' ','')
   update Imports.staging.AgentMetrics	SET	[ACW_%]	=	Replace([ACW_%],' ','')
   update Imports.staging.AgentMetrics	SET	[ACD_(sec)]	=	Replace([ACD_(sec)],' ','')
   update Imports.staging.AgentMetrics	SET	[ACW_(sec)]	=	Replace([ACW_(sec)],' ','')
   update Imports.staging.AgentMetrics	SET	[NC0ACW_(sec)]	=	Replace([NC0ACW_(sec)],' ','')
   update Imports.staging.AgentMetrics	SET	[AHT_(sec)]	=	Replace([AHT_(sec)],' ','')
   update Imports.staging.AgentMetrics	SET	[Accuracy]	=	Replace([Accuracy],' ','')
   update Imports.staging.AgentMetrics	SET	[ACS]	=	Replace([ACS],' ','')
   update Imports.staging.AgentMetrics	SET	[Office]	=	Replace([Office],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX_0]	=	Replace([AUX_0],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX_1]	=	Replace([AUX_1],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX_3]	=	Replace([AUX_3],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX_RONA]	=	Replace([AUX_RONA],' ','')
   update Imports.staging.AgentMetrics	SET	[ACW_%_avg]	=	Replace([ACW_%_avg],' ','')
   update Imports.staging.AgentMetrics	SET	[ISP]	=	Replace([ISP],' ','')
   update Imports.staging.AgentMetrics	SET	[Staffed_Time]	=	Replace([Staffed_Time],' ','')
   update Imports.staging.AgentMetrics	SET	[Hours]	=	Replace([Hours],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX_total_sec]	=	Replace([AUX_total_sec],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX_0_sec]	=	Replace([AUX_0_sec],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX_1_sec]	=	Replace([AUX_1_sec],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX_3_sec]	=	Replace([AUX_3_sec],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX_RONA_sec]	=	Replace([AUX_RONA_sec],' ','')
   update Imports.staging.AgentMetrics	SET	[Staffed_Time_sec]	=	Replace([Staffed_Time_sec],' ','')
   update Imports.staging.AgentMetrics	SET	[AUX1s]	=	Replace([AUX1s],' ','')
   update Imports.staging.AgentMetrics	SET	[ACWs]	=	Replace([ACWs],' ','')
   update Imports.staging.AgentMetrics	SET	[CC_%]	=	Replace([CC_%],' ','')
   update Imports.staging.AgentMetrics	SET	[CC_#]	=	Replace([CC_#],' ','')
   update Imports.staging.AgentMetrics	SET	[CC_score]	=	Replace([CC_score],' ','')
   update Imports.staging.AgentMetrics	SET	[CC_max]	=	Replace([CC_max],' ','')
   update Imports.staging.AgentMetrics	SET	[ACS_%]	=	Replace([ACS_%],' ','')
   update Imports.staging.AgentMetrics	SET	[ACS_#]	=	Replace([ACS_#],' ','')
   update Imports.staging.AgentMetrics	SET	[ACS_score]	=	Replace([ACS_score],' ','')
   update Imports.staging.AgentMetrics	SET	[ACS_max]	=	Replace([ACS_max],' ','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACS]	=	Replace([BSC_ACS],' ','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACC]	=	Replace([BSC_ACC],' ','')
   update Imports.staging.AgentMetrics	SET	[BSC_C2C]	=	Replace([BSC_C2C],' ','')
   update Imports.staging.AgentMetrics	SET	[BSC_ACW]	=	Replace([BSC_ACW],' ','')
   update Imports.staging.AgentMetrics	SET	[BSC_UPOM]	=	Replace([BSC_UPOM],' ','')
   update Imports.staging.AgentMetrics	SET	[BSC_CC]	=	Replace([BSC_CC],' ','')
   update Imports.staging.AgentMetrics	SET	[BSC_AHT]	=	Replace([BSC_AHT],' ','')
   update Imports.staging.AgentMetrics	SET	[BSC]	=	Replace([BSC],' ','')
   update Imports.staging.AgentMetrics	SET	[AHT_Rep]	=	Replace([AHT_Rep],' ','')


  




  select 

CAST([year] AS INT)[year],
CAST([half] AS VARCHAR(10)) [half],
CAST([quarter] AS VARCHAR(10)) [quarter],
CAST([month] AS INT)[month],
CAST([Week_num] AS INT) [Week_num],
CAST([Week_of] AS DATE) [Week_of],
CAST([Rep] AS  VARCHAR(255))[Rep],
CAST([Rep_ID] AS INT)[Rep_ID],
CAST([Rep_ID4] AS INT)[Rep_ID4],
CAST([Sup] AS VARCHAR(255))[Sup],
CAST([DAX_ID] AS VARCHAR(255))[DAX_ID],
CAST([ACD_Calls] AS INT)[ACD_Calls],
CAST([ACD] AS TIME)[ACD],
CAST([ACW] AS  TIME)[ACW],
CAST([AHT] AS  TIME)[AHT],
CAST([AUX] AS VARCHAR(255))[AUX],
CAST([Adherence] AS DECIMAL(18, 2))[Adherence],
CAST([AHT_AVG] AS TIME)[AHT_AVG],
CAST([AHT_SDEV] AS TIME)[AHT_SDEV],
CAST([AHT_UCL] AS TIME)[AHT_UCL],
CAST([AHT_LCL] AS TIME)[AHT_LCL],
CAST([C2C_AVG] AS DECIMAL(18, 2))[C2C_AVG],
CAST([C2C_SDEV] AS DECIMAL(18, 2))[C2C_SDEV],
CAST([C2C_UCL] AS DECIMAL(18, 2)) [C2C_UCL],
CAST([C2C_LCL] AS DECIMAL(18, 2))[C2C_LCL],
CAST([Cross0Sell_Orders] AS INT)[Cross0Sell_Orders],
CAST([Total_Orders] AS INT)[Total_Orders],
CAST([Conversion_%] AS   DECIMAL(18 ,4))/100 [Conversion_%],
CAST([Cross0Sell_USD] AS MONEY)[Cross0Sell_USD],
CAST([Cross0Sell_GBP] AS MONEY)[Cross0Sell_GBP],
CAST([Cross0Sell_AUD] AS MONEY)[Cross0Sell_AUD],
CAST([Cross0Sell_$] AS MONEY)[Cross0Sell_$],
CAST([URPO] AS MONEY)[URPO],
[UPC][UPC],
[UPOM][UPOM],
CAST([URPO_AVG] AS MONEY)[URPO_AVG],
CAST([UPC_AVG] AS MONEY)[UPC_AVG],
CAST([UPOM_AVG] AS MONEY)[UPOM_AVG],
CAST([Errors] AS INT)[Errors],
CAST([Week_of_Filter] AS DATE)[Week_of_Filter],
CAST([Torch_Team] AS VARCHAR(255))[Torch_Team],
[Avg_Non0Call_ACW],
CAST([AUX_%] AS DECIMAL(18, 4))/100[AUX_%],
CAST([ACW_%] AS DECIMAL(18 ,4))/100 [ACW_%],
CAST([ACD_(sec)] AS INT)[ACD_(sec)],
CAST([ACW_(sec)] AS INT)[ACW_(sec)],
CAST([NC0ACW_(sec)] AS INT)[NC0ACW_(sec)],
CAST([AHT_(sec)] AS INT)[AHT_(sec)],
CAST([Accuracy] AS DECIMAL(18, 4))/100 [Accuracy],
cast(	ACS AS varchar) ACS,
CAST([Office] AS VARCHAR(255)) OFFICE,
[AUX_0]  ,
[AUX_1] ,
[AUX_3],
[AUX_RONA],


CAST([ACW_%_avg] AS DECIMAL(18 ,4))/100 	   [ACW_%_avg]	,
CAST([ISP] AS VARCHAR(255))	      [ISP]	,
[Staffed_Time]	      [Staffed_Time]	,
[Hours]	      [Hours]	,
CAST([AUX_total_sec] AS INT	)      [AUX_total_sec]	,
CAST([AUX_0_sec] AS INT)	      [AUX_0_sec]	,
CAST([AUX_1_sec] AS INT)	      [AUX_1_sec]	,
      CAST([AUX_3_sec] AS INT)	      [AUX_3_sec]	,
      CAST([AUX_RONA_sec] AS INT)	      [AUX_RONA_sec]	,
CAST([Staffed_Time_sec] AS INT)	      [Staffed_Time_sec]	,
CAST([AUX1s] AS DECIMAL(18 ,4))/100 	      [AUX1s]	,
CAST([ACWs] AS DECIMAL(18 ,4))/100 	      [ACWs]	,
CAST([CC_%] AS DECIMAL(18, 4))/100 	      [CC_%]	,
CAST([CC_#] AS INT)	      [CC_#]	,
CAST([CC_score] AS INT)	      [CC_score]	,
CAST([CC_max] AS INT)	      [CC_max]	,
CAST([ACS_%] AS DECIMAL(18, 4))/100	      [ACS_%]	,
CAST([ACS_#] AS INT)	      [ACS_#]	,
CAST([ACS_score] AS INT)	      [ACS_score]	,
CAST([ACS_max] AS INT)	      [ACS_max]	,
CAST([BSC_ACS] AS INT)	      [BSC_ACS]	,
CAST([BSC_ACC] AS INT)	      [BSC_ACC]	,
CAST([BSC_C2C] AS INT)	      [BSC_C2C]	,
CAST([BSC_ACW] AS INT)	      [BSC_ACW]	,
CAST([BSC_UPOM] AS INT)	      [BSC_UPOM]	,
CAST([BSC_CC] AS INT)	      [BSC_CC]	,
CAST([BSC_AHT] AS INT)	      [BSC_AHT]	,
CAST([BSC] AS DECIMAL(18, 4))/100	      [BSC]	,
CAST([AHT_Rep] AS varchar(255)	)      [AHT_Rep]	,

GETDATE() AS DMLastUpdated

into #temp1
FROM IMPORTS.STAGING.AgentMetrics


insert  into Imports.CallCenter.AgentMetrics 

select * from #temp1


GO
