SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Android_Load_PlayApps] 
as      
Begin      

/*Update Previous Counts*/
--exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCplus_ios_events_report'
       
--#playApps 
	select 
	ProductTitle,ProductType,Description,Dateadd(HH,3,CAST(TransactionDate AS DATETIME) + CAST(replace(replace(TransactionTime,'PST',''),'PDT','') AS DATETIME)) as TransactionDatetime,TaxType,TransactionType,RefundType,
	Productid,SkuId,Hardware,BuyerCountry,BuyerState,BuyerPostalCode,BuyerCurrency,AmountBuyerCurrency,
	CurrencyConversionRate,MerchanCurrency,AmountMerchantCurrency
	into #playApps
	from  staging.Android_ssis_PlayApps

 Delete A from Archive.Tgcplus_Android_PlayApps A
 join #playApps S
 on S.TransactionDatetime = A.TransactionDatetime


 insert into Archive.Tgcplus_Android_PlayApps  
 (ProductTitle,ProductType,Description,TransactionDate,TransactionDatetime,TaxType,TransactionType,RefundType,
	Productid,SkuId,Hardware,BuyerCountry,BuyerState,BuyerPostalCode,BuyerCurrency,AmountBuyerCurrency,
	CurrencyConversionRate,MerchanCurrency,AmountMerchantCurrency)

 select ProductTitle,ProductType,Description,Cast(TransactionDatetime as date)TransactionDate,TransactionDatetime,TaxType,TransactionType,RefundType,
	Productid,SkuId,Hardware,BuyerCountry,BuyerState,BuyerPostalCode,BuyerCurrency,AmountBuyerCurrency,
	CurrencyConversionRate,MerchanCurrency,AmountMerchantCurrency
 from #playApps S

  
/*Update Counts*/
--exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCplus_ios_events_report'
      
END 
GO
