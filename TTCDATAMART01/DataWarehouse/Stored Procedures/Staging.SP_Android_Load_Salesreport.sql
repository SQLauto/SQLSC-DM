SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [Staging].[SP_Android_Load_Salesreport] 
as      
Begin      

/*Update Previous Counts*/
--exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCplus_ios_events_report'
       
 
 Delete A from Archive.Tgcplus_Android_Salesreport A
 join staging.Android_ssis_Salesreport S
 on S.[OrderChargedDate] = A.[OrderChargedDate]


 insert into Archive.Tgcplus_Android_Salesreport  
 (OrderNumber,OrderChargedDate,OrderChargedTimestamp,FinancialStatus,DeviceModel,ProductTitle,ProductID,ProductType,SKUID,CurrencyofSale,
 ItemPrice,TaxesCollected,ChargedAmount,CityofBuyer,StateofBuyer,PostalCodeofBuyer,CountryofBuyer)

 select OrderNumber,OrderChargedDate,OrderChargedTimestamp,FinancialStatus,DeviceModel,ProductTitle,ProductID,ProductType,SKUID,CurrencyofSale,
 ItemPrice,TaxesCollected,ChargedAmount,CityofBuyer,StateofBuyer,PostalCodeofBuyer,CountryofBuyer
 from staging.Android_ssis_Salesreport S


/*Update Counts*/
--exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCplus_ios_events_report'
      
END      
GO
