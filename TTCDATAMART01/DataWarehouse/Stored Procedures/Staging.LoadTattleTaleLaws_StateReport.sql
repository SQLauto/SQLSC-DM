SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Staging].[LoadTattleTaleLaws_StateReport]
	@TaxYear int = null
as
	declare 
    	@ReportDate datetime
begin
	set nocount on
    
    set @ReportDate = getdate()
	set @TaxYear = coalesce(@TaxYear, year(dateadd(year,-1,getdate())))
 
	print 'Tax Year = ' + convert(varchar,@TaxYear)

		if object_id('Staging.TempTattletaleTaxLawOrders') is not null drop table Staging.TempTattletaleTaxLawOrders
   
		select convert(varchar(20),'TGC') as BusinessUnit
			,year(a.DateOrdered) TaxYear
			,a.DateOrdered
			,a.CustomerID
			,tt.TGCP_ID as TGCPlus_CustomerID
			,a.OrderID
			,a.CurrencyCode
			,ShipFullName
			,ShipAddress
			,ShipAddress2
			,ShipCity
			,ShipRegion
			,ShipPostalCode
			,ShipCountryCode
			,BillingName
			,BillingAddress
			,BillingAddress2
			,BillingAddress3
			,BillingCity
			,BillingRegion
			,BillingPostalCode
			,BillingCountryCode

			,a.GiftFlag
			,TotalReadyCost as TotalSales
			,DiscountAmount as TotalDiscount
			,ShippingCharge as TotalShippingcharge
			,TotalReadyTaxCost as TotalTax
			,a.StatusCode as OrderStatus
			,b.SalesStatusValue as OrderStatusName
			,d.PmtStatus as PaymentStatus
			,c.PaymentStatusValue
			,a.SalesTypeID
			,st.SalesTypeValue
			,d.StockItemID as Item_SKU
			,ii.Description as Item_Name
			,ii.MediaTypeID as Item_MediaType
			,case when replace(ii.MediaTypeID,' ','') in ('DVD','CD','Transcript') then 'Physical'
					when replace(ii.MediaTypeID,' ','') in ('DownloadV','DownloadA','DownloadT') then 'Digital'
					else 'Other'
				end as Item_DigitalPhysical
			,datawarehouse.Staging.Proper(convert(varchar(20),ii.ItemCategoryID)) as Item_Category
			,d.Quantity as Item_Quantity
			,d.SalesPrice as Item_Sales
			,(d.Quantity * d.SalesPrice) Item_TotalSalesPrice
			,getdate() as ReportDate
		into Staging.TempTattletaleTaxLawOrders
		from DataWarehouse.Staging.vwOrders a left join
			DataWarehouse.Staging.vwOrderItems d on a.OrderID = d.OrderID left join
			DAXImports..DAX_SalesStatus b on a.StatusCode = b.SalesStatusCode left join
			DAXImports..DAX_PaymentStatus c on d.PmtStatus = c.PaymentStatusCode left join
			DAXImports..DAX_SalesType st on a.SalesTypeID = st.SalesTypeID left join
			DataWarehouse.Staging.InvItem ii on d.StockItemID = ii.StockItemID left join
			(select distinct customerId, TGCP_ID 
			from DataWarehouse.Mapping.TGC_TGCplus)tt on a.CustomerID = tt.CustomerID
		where year(DateOrdered) = @TaxYear
		and ShipCountryCode like 'US%'
		and ShipRegion in (Select distinct State
							from Mapping.TattletaleTaxLawStates)
		and a.TotalReadyCost <> 0

		-- Get TGC Plus information where applicable
		union all
		select distinct convert(varchar(20),'Plus') as BusinessUnit
			,year(a.completed_at) TaxYear
			,a.completed_at as DateOrdered
			,b.CustomerID
			,a.user_id as TGCPlus_CustomerID
			,convert(varchar,a.id) as OrderID
			,isnull(a.charged_amount_currency_code,'USD') as CurrencyCode
			,DataWarehouse.staging.proper(c.FirstName) + ' ' + DataWarehouse.staging.proper(c.LastName) as ShipFullName
			,c.Address1 as ShipAddress
			,c.Address2 + ' ' + c.Address3 as ShipAddress2
			,c.City as ShipCity
			,c.State as ShipRegion
			,c.ZipCode as ShipPostalCode
			,c.CountryCode as ShipCountryCode
			,DataWarehouse.staging.proper(c.FirstName) + ' ' + DataWarehouse.staging.proper(c.LastName) as BillingName
			,c.Address1 as BillingAddress
			,c.Address2 as BillingAddress2
			,c.Address3 as BillingAddress3
			,c.City as BillingCity
			,c.State as BillingRegion
			,c.ZipCode as BillingPostalCode
			,'US' as BillingCountryCode

			,0 as GiftFlag
			,case when a.type = 'REFUND' then a.pre_tax_amount * -1
				else a.pre_tax_amount
			end as TotalSales
			,0 as TotalDiscount
			,0 as TotalShippingcharge
			,a.tax_amount as TotalTax
			,null as OrderStatus
			,null as OrderStatusName
			,null as PaymentStatus
			,DataWarehouse.staging.proper(a.type) as PaymentStatusValue
			,null as SalesTypeID
			,a.type SalesTypeValue
			,convert(varchar,a.subscription_plan_id) as Item_SKU
			,sp.Description as Item_Name
			,'Streaming' as Item_MediaType
			,'Digital' as Item_DigitalPhysical
			,'Subscription' as Item_Category
			,null as Item_Quantity
			,null as Item_Sales
			,case when a.type = 'REFUND' then a.pre_tax_amount * -1
				else a.pre_tax_amount
			end as Item_TotalSalesPrice
			,getdate() as ReportDate
		from DataWarehouse.Archive.TGCPlus_UserBilling a 
		left join DataWarehouse.Mapping.TGC_TGCplus b on a.user_id = b.TGCP_ID 
		left join DataWarehouse.Marketing.TGCPlus_CustomerSignature c on a.user_id = c.CustomerID
		left join datawarehouse.archive.TGCPlus_SubscriptionPlan sp on a.subscription_plan_id = sp.id
		where year(a.completed_at) = @TaxYear
		and a.payment_handler In ('Stripe','Amazon Payments')
		and c.state in (Select distinct State
							from Mapping.TattletaleTaxLawStates)
		and a.pre_tax_amount <> 0



	-- Load it into final table 
	
	delete a
	from Exports..TattletaleTaxLawOrders a 
	where TaxYear = @TaxYear

	insert into Exports..TattletaleTaxLawOrders
	select *
	from Staging.TempTattletaleTaxLawOrders

	drop table Staging.TempTattletaleTaxLawOrders

end
GO
