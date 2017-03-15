SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_OrdAllctn_Weekly] @GBP float,@AUD float,@ReportWeek Date = null
as
----------------------------------------------------------------------------------
-- Order Allocation process
-- New rules - test

-- PR
-- 11/14/2013

-- UPDATED: 12/4/2013

-- time frame March to May 2013
----------------------------------------------------------------------------------

-- ********************************************************
-- To Change 
-- Forecast week date: @ForecastWeek – Monday of the Forecast week. So it will be Monday of prior week
-- Forecast Week Date2: @ForecastWeek
-- Start and end dates: do these first and then the week of to avoid errors in dates
-- EndDate: @ForecastWeekEnd  -- end Sunday
-- StartDate: @ForecastWeekStart -- begin Sunday

-- @ForecastWeekSaturday as ToDate,  -- End Saturday

-- @ForecastWeekStart as FromDate,
-- Week of: @ForecastWeekStart and @ForecastWeekEnd
-- Change the end of the week: StartDate <= @ForecastWeekSaturday  -- Saturday

-- Change Exchange rates: Based on http://www.bloomberg.com/markets/currencies/currency-converter/
-- 'GBP' then 1.2386
-- 'AUD' then 0.7602


-- ********************************************************

-- 1. Identify web default codes
----------------------------------------------------------------------------------
-- Main ones that are constant: 
-- Catalogcodes are 2, 999, 4289 and 5265
----------------------------------------------------------------------------------
Begin


Declare	@ForecastWeek Date ,    
        @ForecastWeekStart Date ,     
        @ForecastWeekEnd Date,    
        @ForecastWeekSaturday Date,
        @CurrentWeekMonday Date ,    
        @ControlEmailType Varchar(50),    
        @TestEmailType Varchar(50),    
        @ForecastWeekID varchar(20),    
        @SQL Varchar(1000) 
       

if @ReportWeek is null 
set @ReportWeek = GETDATE()

      
--ForecastWeekMonday    
set @ForecastWeek = DateAdd(d,-7,Datawarehouse.staging.GetMonday(@ReportWeek))    
--ForecastWeekSunday    
set @ForecastWeekStart = DATEADD(D,-1,@ForecastWeek)    
--ForecastWeekNextSunday    
set @ForecastWeekEnd = DATEADD(D,6,@ForecastWeek)    
--ForecastWeekID    
Set @ForecastWeekID =convert(char(8), @ForecastWeek, 112)     

set @ForecastWeekSaturday =  DATEADD(D,-1,@ForecastWeekEnd)    

select @ForecastWeek as ForecastWeek,@ForecastWeekStart as ForecastWeekStart
,@ForecastWeekEnd ForecastWeekEnd,@ForecastWeekSaturday as ForecastWeekSaturday
,@ForecastWeekID ForecastWeekID


--Truncate weekly table
Truncate table staging.OrdAllctn_UnsourcedCatalogCodes_weekly




/* Insert Deafult values*/

Insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly values (2)
Insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly values (999)
Insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly values (4289)
Insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly values (5265)
Insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly values (41757)

-- Au Web Defaults
Insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly values (16318)
Insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly values (14602)

-- UK Web Defaults
Insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly values (11519)
Insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly values (11633)

-- Default app code
Insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly values (36655)


insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly
select distinct a.CatalogCode 
from DataWarehouse.Mapping.vwAdcodesAll a left join
	staging.OrdAllctn_UnsourcedCatalogCodes_weekly b on a.CatalogCode = b.CatalogCode
where a.MD_PromotionTypeID in (81,158)
and b.CatalogCode is null


insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly
select distinct a.CatalogCode 
from DataWarehouse.Mapping.vwAdcodesAll a left join
	staging.OrdAllctn_UnsourcedCatalogCodes_weekly b on a.CatalogCode = b.CatalogCode
where a.MD_PromotionTypeID in (169,168)
and b.CatalogCode is null


 select * from datawarehouse.staging.OrdAllctn_UnsourcedCatalogCodes_weekly

/* 2.  Identify Branded Paid search codes */
-- include house lost codes that had sales during that time period
-- drop table #TempAdcodeWthSales
	select distinct adcode
	into #TempAdcodeWthSales
	from DataWarehouse.staging.vwOrders
	where DateOrdered between @ForecastWeekStart and @ForecastWeekEnd

-- include house lost codes that had sales during that time period
-- drop table #TempAdcodeWthSales2
	select distinct adcode
	into #TempAdcodeWthSales2
	from DataWarehouse.Marketing.DMPurchaseOrders
	where DateOrdered between @ForecastWeekStart and @ForecastWeekEnd

--select PromotionTypeID, PromotionType, PromotionTypeFlag2
--from MarketingCubes..DimPromotionType
--where PromotionTypeFlag2 = 'ecom'
--and PromotionType like 'Paid%'

/*
PromotionTypeID PromotionType                                      PromotionTypeFlag2
--------------- -------------------------------------------------- ------------------------------
2654            Paid Search - Brand                                Ecom
2656            Paid Search - Brand Buffet                         Ecom

(4 row(s) affected)

-- NOt using these as they are Non brand
2655            Paid Search - NonBrand                             Ecom
2657            Paid Search - NonBrand Buffet                      Ecom
*/


--drop table #tempPROM
select distinct a.CatalogCode
into #tempPROM
from DataWarehouse.Mapping.vwAdcodesAll a join
	#TempAdcodeWthSales b on a.AdCode = b.AdCode
where  a.PromotionTypeID in (2654, 2656)

insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly
select a.*
from #tempPROM a left join
	staging.OrdAllctn_UnsourcedCatalogCodes_weekly b on a.CatalogCode = b.CatalogCode
where b.CatalogCode is null	

-- check for any other Branded paid search.
--drop table #tempPROMSearch

select distinct a.CatalogCode
into #tempPROMSearch
from DataWarehouse.Mapping.vwAdcodesAll a join
	#TempAdcodeWthSales b on a.AdCode = b.AdCode
where channelID = 11
and md_PromotiontypeId in (146, 64)

insert into staging.OrdAllctn_UnsourcedCatalogCodes_weekly
select a.*
from #tempPROMSearch a left join
	staging.OrdAllctn_UnsourcedCatalogCodes_weekly b on a.CatalogCode = b.CatalogCode
where b.CatalogCode is null	

select top 10 * from  staging.OrdAllctn_UnsourcedCatalogCodes_weekly

--select * from Mapping.vwAdcodesAll
--where CatalogCode in (select distinct CatalogCode from staging.OrdAllctn_UnsourcedCatalogCodes_weekly)


-- 3. Identify house lost codes
----------------------------------------------------------------------------------
select * from DataWarehouse.Mapping.vwAdcodesAll
where AdcodeName like '%lost%code%'
and StopDate >= @ForecastWeekStart
and StartDate < @ForecastWeekEnd

Truncate table  Staging.OrdAllctn_UnsourcedLostCodesWeekly

insert into Staging.OrdAllctn_UnsourcedLostCodesWeekly
select distinct a.AdCode
from DataWarehouse.Mapping.vwAdcodesAll a join
	#TempAdcodeWthSales b on a.AdCode = b.AdCode left join
	staging.OrdAllctn_UnsourcedCatalogCodes_weekly c on a.CatalogCode = c.CatalogCode join
	MarketingCubes..DimPromotionType d on a.PromotionTypeID = d.PromotionTypeID
where  a.AdcodeName like '%lost%code%'
and c.CatalogCode is null
and d.PromotionTypeFlag in ('House_Print')


--insert into Staging.OrdAllctn_UnsourcedLostCodesWeekly
--select distinct AdCode
--from mapping.vwadcodesall
--where adcode in (112666,112667,112668,112672)


--select * from Staging.OrdAllctn_UnsourcedLostCodesWeekly
--where adcode in (112666,112667,112668,112672)


select * from Mapping.vwAdcodesAll
where AdCode in (select distinct AdCode from Staging.OrdAllctn_UnsourcedLostCodesWeekly)


--select * from DataWarehouse.Mapping.vwAdcodesAll
--where CatalogCode in (select distinct CatalogCode from staging.OrdAllctn_UnsourcedCatalogCodes_weekly)
--and adcode in (112666,112667,112668,112672)


-------------------------- -------------------------- -------------------------- 
-------------------------- Create main table
-------------------------- -------------------------- -------------------------- 



drop table staging.OrdAllctn_AllOrders_weekly


select @ForecastWeekStart as FromDate,
	@ForecastWeekSaturday as ToDate,
	Staging.GetMonday(a.Dateordered) as ForecastWeek,
	a.OrderID, a.CustomerID, year(a.DateOrdered) YearOrdered,
	a.NetOrderAmount, 
	MONTH(a.DateOrdered) as MonthOrdered,
	Staging.GetMonday(a.DateOrdered) as WeekOfOrder,
	 case when b.countryID = 1 then 4
		when b.countryID  = 2 then 2
		when b.countryID  = 3 then 3
		else 1
	end FlagCountry,
	CAST(a.DateOrdered as DATE) DateOrdered,
	a.OrderSource,
	b.StartDate, b.StopDate, 
	DATEDIFF(WEEK, Staging.GetMonday(a.DateOrdered), b.StopDate) WeekDiff,
	isnull(c.FlagUnsourcedOrder,0) FlagUnsourcedOrder,
	a.AdCode, b.AdcodeName, b.CatalogCode, b.CatalogName,
	b.PromotionTypeID, b.PromotionType,
	b.CountryID as MD_CountryID, b.MD_Country, 
	b.AudienceID as MD_AudienceID,  b.MD_Audience,
	b.ChannelID as MD_ChannelID, b.MD_Channel, 
	b.MD_PromotionTypeID, b.MD_PromotionType, 
	b.MD_CampaignID, b.MD_CampaignName,
	b.MD_Year,
	b.PriceTypeID as MD_PriceTypeID, 
	convert(varchar,b.PriceTypeID) + '_' + b.MD_PriceType as MD_PriceType,
	
	/* Assign to new set of Dimensions */
	b.CountryID as Asn_CountryID, b.MD_Country as Asn_Country, 
	b.AudienceID as Asn_AudienceID,  b.MD_Audience as Asn_Audience,
	b.ChannelID as Asn_ChannelID, b.MD_Channel as Asn_Channel, 
	b.MD_PromotionTypeID as Asn_PromotionTypeID, b.MD_PromotionType Asn_PromotionType, 
	b.MD_CampaignID Asn_CampaignID, b.MD_CampaignName Asn_CampaignName,
	b.MD_Year Asn_Year,
	b.PriceTypeID as Asn_PriceTypeID, 
	convert(varchar,b.PriceTypeID) + '_' + b.MD_PriceType as Asn_PriceType,
	CONVERT(int,0) Asn_CatalogCode,
	CONVERT(varchar(75),null) as Asn_CatalogName,

	e.Coupon, e.CouponDesc,
	CONVERT(int,0) as AssignedCode,
	CONVERT(varchar(50),null) AssignedName,
	convert(tinyint,0) FlagRecvdCampaign ,
	convert(int, null) CouponPriorityCode,
	convert(int, null) CouponCatalogCode,
	convert(varchar(50), null) CouponCatalogCodeName,
	convert(varchar(50), null) CouponAdCodeName,
	CONVERT(varchar(50), null) AssignReason,
	convert(int, null) CrsMatchCatalogCode,
	convert(varchar(50), null) CrsMatchCatalogName ,
	F.SequenceNum,
	case when f.SequenceNum = 1 then 1
		else 0
	end FlagNewCustomer,
	F.NamePrior,
	F.FlagDigitalPhysical,
	a.CurrencyCode, 
	case when a.BillingCountryCode in ('CA','GB','AU') then a.BillingCountryCode
		else 'US'
	end as BillingCountryCode,
	
	CONVERT(money,0) as CD_Sales,
	CONVERT(money,0) as CD_Parts,
	CONVERT(money,0) as DVD_Sales,
	CONVERT(money,0) as DVD_Parts,
	CONVERT(money,0) as DownloadA_Sales,
	CONVERT(money,0) as DownloadA_Parts,
	CONVERT(money,0) as DownloadV_Sales,
	CONVERT(money,0) as DownloadV_Parts,
	CONVERT(money,0) as Transcript_Sales,
	CONVERT(money,0) as Transcript_Parts,
	case when a.CurrencyCode = 'GBP' then @GBP
		when a.CurrencyCode = 'AUD' then @AUD  
		else 1
	end as ExchangeRate,
	CONVERT(money,0) as NetOrderAmountDllrs,
		CONVERT(money,0) as CD_SalesDllrs,
	CONVERT(money,0) as DVD_SalesDllrs,
	CONVERT(money,0) as DownloadA_SalesDllrs,
	CONVERT(money,0) as DownloadV_SalesDllrs,
	CONVERT(money,0) as Transcript_SalesDllrs,
	CONVERT(money,0) as Tax,
	CONVERT(money,0) as TaxDllrs
	
into staging.OrdAllctn_AllOrders_weekly
from DataWarehouse.Staging.vwOrders a 
	left join 
	DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode 
	left join
	(select distinct a.*, 1 as FlagUnsourcedOrder
	from DataWarehouse.Mapping.vwAdcodesAll a join
		DataWarehouse.staging.OrdAllctn_UnsourcedCatalogCodes_weekly b on a.CatalogCode = b.CatalogCode)c 
															on a.AdCode = c.CatalogCode 
	left join
	DAXImports..DAX_OrderCouponsExport e on a.OrderID = e.salesid 
	left join
	DataWarehouse.Marketing.DMPurchaseOrders f on a.orderid = f.orderid
where a.DateOrdered between @ForecastWeekStart and @ForecastWeekEnd
and a.NetOrderAmount > 0
and a.OrderID not like 'r%'
and a.StatusCode in (0, 1, 2, 3, 12, 13, 8) 
-- (14680 row(s) affected)


-------------------------- -------------------------- -------------------------- 
------- Orders With Payment Rejected	
-------------------------- -------------------------- -------------------------- 

drop table Staging.OrdAllctn_OrdersWithPaymentReject_weekly;

------- DAX
select  			
a.OrderID,	
b.Sales, 	 -- DAX				
a.NetOrderAmount				
into Staging.OrdAllctn_OrdersWithPaymentReject_weekly				
from DataWarehouse.Staging.vwOrders a				
join (select OrderID, SUM(AMOUNT) Sales from DataWarehouse.Staging.OrderPayments 
		where status=2 group by OrderID) b -- DAX
on convert(varchar, a.OrderID) = convert(varchar, b.OrderID)		
where a.DateOrdered between @ForecastWeekStart and @ForecastWeekEnd
-- 9 rows affected

	 	
update a
set a.NetOrderAmount = a.NetOrderAmount-b.Sales
from staging.OrdAllctn_AllOrders_weekly a  join
	 	Staging.OrdAllctn_OrdersWithPaymentReject_weekly	b on a.OrderID = b.OrderID
-- 9 rows affected

-------------------------- -------------------------- -------------------------- 
-- UPdate FlagUnsourcedOrder to 1 for lost codes
-------------------------- -------------------------- -------------------------- 

update a
set a.FlagUnsourcedOrder = 1
-- select a.*
from staging.OrdAllctn_AllOrders_weekly a join
	staging.OrdAllctn_UnsourcedCatalogCodes_weekly b on a.CatalogCode = b.CatalogCode
-- (7535 row(s) affected)

-------------------------- -------------------------- -------------------------- 
-- UPdate for expired mailings
-------------------------- -------------------------- -------------------------- 
update staging.OrdAllctn_AllOrders_weekly
set Asn_ChannelID = case when MD_Audience = 'House' then 1000
							else 1001
						end,
	Asn_Channel = case when MD_Audience = 'House' then 'Expired House DirectMail'
							else 'Expired Prospect DirectMail'
						end,
	Asn_CatalogCode = case when MD_Audience = 'House' then 1000
							else 1001
						end,
	Asn_CatalogName = case when MD_Audience = 'House' then 'Expired House DirectMail'
							else 'Expired Prospect DirectMail'
						end,						
	AssignedCode = 4,
	AssignedName = 'MD_Channel'	,				
	AssignReason = case when MD_Audience = 'House' then 'Expired House DirectMail'
							else 'Expired Prospect DirectMail'
						end
-- select * from  staging.OrdAllctn_AllOrders_weekly						
where MD_Channel in ('House Mailings', 'Prospect Mailings', '3rd Party Inserts')
and WeekDiff < -2
--and StartDate >= '1/1/2012'
--and FlagUnsourcedOrder = 0
-- (83 row(s) affected)



--------------------------------------------------------------------------------
-- update codes for future mailings..
--------------------------------------------------------------------------------

update staging.OrdAllctn_AllOrders_weekly
set Asn_ChannelID = case when MD_Audience = 'House' then 1002
							else 1003
						end,
	Asn_Channel = case when MD_Audience = 'House' then 'Future House DirectMail'
							else 'Future Prospect DirectMail'
						end,
	Asn_CatalogCode = case when MD_Audience = 'House' then 1002
							else 1002
						end,
	Asn_CatalogName = case when MD_Audience = 'House' then 'Future House DirectMail'
							else 'Future Prospect DirectMail'
						end,						
	AssignedCode = 4,
	AssignedName = 'MD_Channel'	,				
	AssignReason = case when MD_Audience = 'House' then 'Future House DirectMail'
							else 'Future Prospect DirectMail'
						end,
	FlagUnsourcedOrder = 1
-- select * from  staging.OrdAllctn_AllOrders_weekly						
where MD_Channel in ('House Mailings', 'Prospect Mailings', '3rd Party Inserts')
and DATEDIFF(WEEK, Staging.GetMonday(DateOrdered), StartDate) > 1
--and StartDate >= '1/1/2012'
and FlagUnsourcedOrder = 0
-- (83 row(s) affected)

-- based on discussions from 4/14 meeting, move all tail adcodes to expired Prospect campaigns
-- PR 4/21/2014
update staging.OrdAllctn_AllOrders_weekly
set Asn_ChannelID = 1001,
	Asn_Channel = 'Expired Prospect DirectMail',
	Asn_CatalogCode = 1001,
	Asn_CatalogName = 'Expired Prospect DirectMail',
	AssignedCode = 4,
	AssignedName = 'MD_Channel',
	AssignReason = 'Expired Prospect DirectMail'
-- select distinct catalogname from  staging.OrdAllctn_AllOrders_weekly						
where  CatalogName like '%tail%'
and MD_Channel = 'Prospect Mailings'
-- (4 row(s) affected)

-------------------------- -------------------------- -------------------------- 
-- update Codes for emails
-------------------------- -------------------------- -------------------------- 

-- Move all NMRs back to rev gen
select * from staging.OrdAllctn_AllOrders_weekly
where MD_Channel in ('House Email')
and CatalogName like '%NMR%'

update staging.OrdAllctn_AllOrders_weekly
set Asn_CatalogCode = 6,
	Asn_CatalogName = 'House Email',
	Asn_PromotionTypeID = 47,
	Asn_PromotionType = 'House Email: Revenue Generating Email',
	AssignedCode = 5,
	AssignedName = 'MD_PromotionType',
	AssignReason = 'Expired Emails'
where MD_Channel in ('House Email')
and CatalogName like '%NMR%'

-- Move all expired DLRs to Rev Gen
select * from staging.OrdAllctn_AllOrders_weekly
where MD_Channel in ('House Email')
and WeekDiff < 0

update staging.OrdAllctn_AllOrders_weekly
set Asn_CatalogCode = 6,
	Asn_CatalogName = 'House Email',
	Asn_PromotionTypeID = 47,
	Asn_PromotionType = 'House Email: Revenue Generating Email',
	AssignedCode = 5,
	AssignedName = 'MD_PromotionType',
	AssignReason = 'Expired Emails'
where MD_Channel in ('House Email')
and WeekDiff < 0


-------------------------- -------------------------- -------------------------- 
-- update Codes for Paid Search
-------------------------- -------------------------- -------------------------- 

update DataWarehouse.staging.OrdAllctn_AllOrders_weekly
set MD_ChannelID = 11,
	MD_Channel = 'Paid Search',
	MD_PromotionTypeID = 146,
	MD_PromotionType = 'Paid Search: Brand',
	
	Asn_ChannelID = 11,
	Asn_Channel = 'Paid Search',
	Asn_PromotionTypeID = 146,
	Asn_PromotionType = 'Paid Search: Brand',
	Asn_CatalogCode = 146,
	Asn_CatalogName = 'Paid Search: Brand',
	
	AssignedCode = 45,
	AssignedName = 'MD_ChannelPromomtionType',
	AssignReason = 'Left in Paid Search: Brand'	
--	select * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 1
and PromotionType = 'Paid Search - Brand'
-- (1178 row(s) affected)

-- for 65, change the Budscategory name
select *
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where PromotionType like '%Displ%'



select * from DataWarehouse.Mapping.vwAdcodesAll
where MD_Year = 2014
and MD_Channel in ('House Mailings')
and MD_PromotionType in ('House Mailings: Catalog', 'House Mailings: Magalog', 'House Mailings: Catalog No 2',
								'House Mailings: Magazine', 'House Mailings: Magnificent 7')

-------------------------- -------------------------- -------------------------- 
-- For Uncoded sales, try to allocate based on courses in the order.
-- Build Active Campaigns table
-------------------------- -------------------------- -------------------------- 								

drop table staging.OrdAllctn_ActiveHouseCampaigns_weekly


select *
into staging.OrdAllctn_ActiveHouseCampaigns_weekly
from DataWarehouse.Mapping.vwAdcodesAll
where MD_Year >= (year(@ForecastWeek) - 1) --2015
and StopDate >= @ForecastWeekStart
and StartDate <= @ForecastWeekSaturday
and MD_Channel in ('House Mailings')
and MD_PromotionType in ('House Mailings: Catalog', 'House Mailings: Magalog', 'House Mailings: Catalog No 2',
								'House Mailings: Magazine', 'House Mailings: Magnificent 7')
and MD_CampaignID <> 1234 -- Based on Joe P's request to remove best customers from allocation								
--union
--select *
----into staging.OrdAllctn_ActiveHouseCampaigns_weekly
--from DataWarehouse.Mapping.vwAdcodesAll
--where MD_Year = 2016
--and StopDate >= @ForecastWeekStart
--and StartDate <= @ForecastWeekSaturday
--and MD_Channel in ('House Mailings')
--and MD_PromotionType in ('House Mailings: Catalog', 'House Mailings: Magalog', 'House Mailings: Catalog No 2',
--								'House Mailings: Magazine', 'House Mailings: Magnificent 7')								
--and MD_CampaignID <> 1234 -- Based on Joe P's request to remove best customers from allocation
--and MD_CampaignName not like '%Best Customer%'-- Based on Joe P's request to remove best customers from allocation
--union
--select *
----into staging.OrdAllctn_ActiveHouseCampaigns_weekly
--from DataWarehouse.Mapping.vwAdcodesAll
--where MD_Year = 2017
--and StopDate >= @ForecastWeekStart
--and StartDate <= @ForecastWeekSaturday
--and MD_Channel in ('House Mailings')
--and MD_PromotionType in ('House Mailings: Catalog', 'House Mailings: Magalog', 'House Mailings: Catalog No 2',
--								'House Mailings: Magazine', 'House Mailings: Magnificent 7')								
--and MD_CampaignID <> 1234 -- Based on Joe P's request to remove best customers from allocation
--and MD_CampaignName not like '%Best Customer%'-- Based on Joe P's request to remove best customers from allocation
	
								
					
select top 10 * from staging.OrdAllctn_ActiveHouseCampaigns_weekly
order by StartDate	

delete from staging.OrdAllctn_ActiveHouseCampaigns_weekly
where AdCode in (28898,28899,44279)

drop table staging.OrdAllctn_ActiveHouseCampaigns_weekly_History


select a.*
into staging.OrdAllctn_ActiveHouseCampaigns_weekly_History
from DataWarehouse.Archive.MailhistoryCurrentYear a join
	staging.OrdAllctn_ActiveHouseCampaigns_weekly b on a.AdCode = b.AdCode
	
-- 1864739

select COUNT(*) from staging.OrdAllctn_ActiveHouseCampaigns_weekly_History

delete from staging.OrdAllctn_ActiveHouseCampaigns_weekly_History
where FlagHoldOut = 1
-- (0 row(s) affected)


--select * from staging.OrdAllctn_ActiveHouseCampaigns_weekly_History
--order by startdate desc



-- Get customers who received these mailings
drop table staging.OrdAllctn_ActiveHouseCampaignRecipient_weekly

select a.*
into staging.OrdAllctn_ActiveHouseCampaignRecipient_weekly
from staging.OrdAllctn_ActiveHouseCampaigns_weekly_History a join
	staging.OrdAllctn_AllOrders_weekly b on a.CustomerID = b.CustomerID
									and a.AdCode = b.AdCode

select COUNT(*) from staging.OrdAllctn_ActiveHouseCampaignRecipient_weekly



select FlagUnsourcedOrder, AssignReason, COUNT(OrderID)
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
group by FlagUnsourcedOrder, AssignReason
order by 1,2
/*
FlagUnsourcedOrder AssignReason                                       
------------------ -------------------------------------------------- -----------
0                  NULL                                               11233
0                  Expired Emails                                     12
0                  Expired House DirectMail                           115
0                  Expired Prospect DirectMail                        62
1                  NULL                                               1818
1                  Left in Paid Search: Brand                         772

(6 row(s) affected)
*/


update a
set FlagRecvdCampaign = 1
-- select a.*
from staging.OrdAllctn_AllOrders_weekly a join
	staging.OrdAllctn_ActiveHouseCampaigns_weekly_History b on a.CustomerID = b.CustomerID
											and a.AdCode = b.AdCode
		
	
select distinct a.AdCode, b.AdcodeName, b.CatalogCode, b.CatalogName,
	b.StartDate, b.StopDate
from staging.OrdAllctn_ActiveHouseCampaigns_weekly_History	a join
	Mapping.vwAdcodesAll b on a.AdCode = b.AdCode
order by b.StartDate	
		
-- download coupon table to OrdAllctn_Coupon	
											
select *
from staging.OrdAllctn_CouponCodesWAdcodes



select FlagUnsourcedOrder, AssignReason, Asn_CatalogCode, Asn_catalogname, COUNT(OrderID)
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 1
group by FlagUnsourcedOrder, AssignReason, Asn_CatalogCode, Asn_catalogname
order by 1,2

/*
FlagUnsourcedOrder AssignReason                                       Asn_CatalogCode Asn_catalogname                                                             
------------------ -------------------------------------------------- --------------- --------------------------------------------------------------------------- -----------
1                  NULL                                               0               NULL                                                                        1818
1                  Left in Paid Search: Brand                         146             Paid Search: Brand                                                          772

(2 row(s) affected)

*/


select top 100 * from staging.OrdAllctn_AllOrders_weekly 

-------------------------- -------------------------- -------------------------- 
--- Allocate Sales based on Sets/bundles purchased and Mail match
-------------------------- -------------------------- -------------------------- 

-- Get Items level information
--drop table #Temp
select b.*,
	a.CourseID, a.BundleID, a.StockItemID,
	a.SalesPrice
into #Temp
from DataWarehouse.Marketing.DMPurchaseOrderItems a join
	staging.OrdAllctn_AllOrders_weekly b on a.OrderID = b.OrderID
where b.FlagUnsourcedOrder = 1	
and b.AssignedCode in (0,45)



select distinct OrderID  
from #Temp
where BundleID > 0

--select * from 	DataWarehouse.staging.OrdAllctn_ActiveHouseCampaigns_weekly


--drop table #temp2set

select distinct a.*,
	CONVERT(int,0) as NumActiveCampaigns,
	b.catalogCode as ActiveCatalogCode,
	b.catalogName as  ActiveCatalogName,
	CONVERT(int,0) as FlagReceivedMail
into #temp2set
from #Temp a join
	(select distinct II.CourseID, MC.CourseName, 
		MC.SubjectCategory2, BundleFlag, mpm.UnitCurrency,
		c.*
	FROM datawarehouse.staging.mktpricingmatrix mpm left outer join
		superstardw.dbo.invitem ii on ii.userstockitemid = mpm.userstockitemid JOIN
		DataWarehouse.Mapping.dmcourse mc on ii.courseid = mc.courseid join
	DataWarehouse.staging.OrdAllctn_ActiveHouseCampaigns_weekly c on mpm.CatalogCode = c.CatalogCode)b 
												on a.BundleID = b.CourseID 
												and a.MD_Country = b.MD_Country
												and a.DateOrdered between b.StartDate and b.StopDate


select top 10 * from #temp2set



-- Now see if customer received that mail file
update a
set FlagRecvdCampaign = 1
-- select a.*
from #temp2set a join
	(select distinct A.customerID, b.CatalogCode, b.StartDate, b.StopDate
	from 	staging.OrdAllctn_ActiveHouseCampaigns_weekly_History a join
			DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode)b on a.CustomerID = b.CustomerID
											and a.ActiveCatalogCode = b.CatalogCode
											and a.DateOrdered between b.StartDate and b.StopDate
where FlagUnsourcedOrder = 1
and AssignedCode = 0	


-- see how many
--drop table #temp3PRset

select distinct OrderID, ActiveCatalogCode, ActiveCatalogName
into #temp3PRset
from #temp2set 
where FlagRecvdCampaign = 1
order by 1,2

select top 10 * from #temp3PRset

-- Update assigned code
--drop table #temp4set

select * 
into #temp4set
from #temp3PRset
where orderid in (select orderid from #temp3PRset
					group by orderid
					having COUNT(activecatalogcode) = 1)
order by 1,2	

select top 10 * from #temp4set


-- FOR MULTIS
--drop table #temp5set

select *, case when MD_PromotionTypeID = 155 then 1
				when MD_PromotionTypeID = 1 then 2
				when MD_PromotionTypeID = 6 then 3
				when MD_PromotionTypeID = 4 then 4
				else 0
			end as Rank
into #temp5set
from #temp3PRset a join
	(select distinct catalogcode, MD_CampaignID, MD_CampaignDesc, MD_PromotionTypeID, MD_PromotionType,
		StartDate
	from DataWarehouse.Mapping.vwAdcodesAll) b on a.ActiveCatalogCode = b.CatalogCode
where orderid in (select orderid from #temp3PRset
					group by orderid
					having COUNT(activecatalogcode) > 1)
order by 1,2	

select top 10 * from #temp5set


--drop table #temp6set

SELECT *,
	 rank() over(partition by orderID order by rank, StartDate desc) as FinalRank  -- PR 1/20/2014 changed to do sorting by startdate desc
into #temp6set
from #temp5set

select top 10 * from #temp6set



--alter table staging.OrdAllctn_AllOrders_weekly add CrsMatchCatalogCode int,	CrsMatchCatalogName varchar(50)

update a
set a.CrsMatchCatalogCode = b.activeCatalogCode,
	a.CrsMatchCatalogName = b.ActiveCatalogName,
	a.flagRecvdCampaign = 1
-- select a.*
from staging.OrdAllctn_AllOrders_weekly a join
	#temp4set b on a.OrderID = b.OrderID
where a.FlagUnsourcedOrder = 1	
and a.AssignedCode in (0,45)


update a
set a.CrsMatchCatalogCode = b.activeCatalogCode,
	a.CrsMatchCatalogName = b.ActiveCatalogName,
	a.flagRecvdCampaign = 1
-- select a.*
from staging.OrdAllctn_AllOrders_weekly a join
	#temp6set b on a.OrderID = b.OrderID
where a.FlagUnsourcedOrder = 1	
and a.AssignedCode =0
and a.CrsMatchCatalogCode is null
and b.finalRank = 1
and a.AssignedCode in (0,45)


-- Reassign identified bundle level match
drop table staging.OrdAllctn_BudCodeAssign_weekly_set

select distinct b.Cpn_ChannelID, b.Cpn_Country,
	b.Cpn_Channel, 
	b.Cpn_PromotionTypeID,
	b.Cpn_PromotionType,
	b.Cpn_CampaignID,
	b.Cpn_CampaignName,
	 a.*
Into staging.OrdAllctn_BudCodeAssign_weekly_set
from staging.OrdAllctn_AllOrders_weekly a join
     (select distinct Catalogcode, MD_Country as Cpn_Country,
		ChannelID as Cpn_ChannelID,
		MD_Channel as Cpn_Channel,
		MD_PromotionTypeID Cpn_PromotionTypeID, MD_PromotionType Cpn_PromotionType,
		MD_CampaignID Cpn_CampaignID, MD_CampaignName Cpn_CampaignName
      from Mapping.vwAdcodesAll) b on a.CrsMatchCatalogCode = b.catalogcode											
where a.FlagUnsourcedOrder = 1	

select top 10  * from staging.OrdAllctn_BudCodeAssign_weekly_set


update a
set a.Asn_CatalogCode = b.CrsMatchCatalogCode,
	a.Asn_CatalogName = b.CrsMatchCatalogName,
	a.AssignedCode = b.CrsMatchCatalogCode,
	a.AssignedName = b.CrsMatchCatalogName,
	a.AssignReason = 'Mail_BundleMatch',
	a.Asn_ChannelID = b.Cpn_ChannelID,
	a.Asn_Channel = b.Cpn_Channel,
	a.Asn_PromotionTypeID = b.Cpn_PromotionTypeID,
	a.Asn_PromotionType = b.Cpn_PromotionType,
	a.Asn_CampaignID = b.Cpn_CampaignID,
	a.Asn_CampaignName = b.Cpn_CampaignName
-- select *
from staging.OrdAllctn_AllOrders_weekly a join
	staging.OrdAllctn_BudCodeAssign_weekly_set b on a.OrderID = b.OrderID
where a.FlagUnsourcedOrder = 1	
and a.flagrecvdcampaign = 1
and a.AssignedCode in (0,45)



select FlagUnsourcedOrder, AssignReason, COUNT(OrderID) Orders
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
group by FlagUnsourcedOrder, AssignReason
order by 1,2


select FlagUnsourcedOrder, convert(varchar(35),AssignReason) AssignReason, 
	Asn_CatalogCode, convert(varchar(35),Asn_catalogname) Asn_catalogname, COUNT(OrderID)
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 1
group by FlagUnsourcedOrder, convert(varchar(35),AssignReason), 
	Asn_CatalogCode, convert(varchar(35),Asn_catalogname)
order by 1,2


-------------------------- -------------------------- -------------------------- 
--- Allocate Sales based on Course purchased and Mail match
-------------------------- -------------------------- -------------------------- 	


--drop table #temp2

select distinct a.*,
	CONVERT(int,0) as NumActiveCampaigns,
	b.catalogCode as ActiveCatalogCode,
	b.catalogName as  ActiveCatalogName,
	CONVERT(int,0) as FlagReceivedMail
into #temp2	
from #Temp a join
	(select distinct c.*, b.UserStockItemID, b.UnitCurrency
	from DataWarehouse.Staging.MktPricingMatrix b join
	DataWarehouse.staging.OrdAllctn_ActiveHouseCampaigns_weekly c on b.CatalogCode = c.CatalogCode)b 
												on a.StockItemID = b.UserStockItemID 
												and a.BillingCountryCode = b.MD_Country
												and a.DateOrdered between b.StartDate and b.StopDate
												


select top 10 * from #temp2

-- update FlagReceivedMail
--select * from 	staging.OrdAllctn_ActiveHouseCampaigns_weekly_History 
 
-- Now see if customer received that mail file
update a
set FlagRecvdCampaign = 1
-- select distinct a.orderid
from #temp2 a join
	(select distinct A.customerID, b.CatalogCode, b.StartDate, b.StopDate
	from 	staging.OrdAllctn_ActiveHouseCampaigns_weekly_History a join
			DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode)b on a.CustomerID = b.CustomerID
											and a.ActiveCatalogCode = b.CatalogCode
											and a.DateOrdered between b.StartDate and b.StopDate
where FlagUnsourcedOrder = 1
and AssignedCode in (0,45)	

select top 10  * from #temp2
where FlagRecvdCampaign = 1

-- see how many
--drop table #temp3PR

select distinct OrderID, ActiveCatalogCode, ActiveCatalogName, BillingCountryCode
into #temp3PR
from #temp2 
where FlagRecvdCampaign = 1
order by 1,2

-- Update assigned code
--drop table #temp4

select * 
into #temp4
from #temp3PR
where orderid in (select orderid from #temp3PR
					group by orderid
					having COUNT(activecatalogcode) = 1)
order by 1,2	

select top 10 * from #temp4


-- FOR MULTIS
--drop table #temp5

select *, case when MD_PromotionTypeID = 155 then 1
				when MD_PromotionTypeID = 1 then 2
				when MD_PromotionTypeID = 6 then 3
				when MD_PromotionTypeID = 4 then 4
				else 0
			end as Rank
into #temp5
from #temp3PR a join
	(select distinct catalogcode, MD_CampaignID, MD_CampaignDesc, MD_PromotionTypeID, MD_PromotionType,
		StartDate
	from DataWarehouse.Mapping.vwAdcodesAll) b on a.ActiveCatalogCode = b.CatalogCode
where orderid in (select orderid from #temp3PR
					group by orderid
					having COUNT(activecatalogcode) > 1)
order by 1,2	

select top 10 * from #temp5

--drop table #temp6
SELECT *,
	 rank() over(partition by orderID order by rank, StartDate desc, CatalogCode) as FinalRank  -- PR 1/20/2014 changed to do sorting by startdate desc
into #temp6
from #temp5




--select * from staging.OrdAllctn_AllOrders_weekly			


update a
set a.CrsMatchCatalogCode = b.activeCatalogCode,
	a.CrsMatchCatalogName = b.ActiveCatalogName,
	a.flagRecvdCampaign = 1
-- select a.*, b.activecatalogcode, b.activecatalogname, b.BillingCountrycode
from staging.OrdAllctn_AllOrders_weekly a join
	#temp4 b on a.OrderID = b.OrderID
where a.FlagUnsourcedOrder = 1
and a.AssignedCode in (0,45)
and CrsMatchCatalogCode is null

update a
set a.CrsMatchCatalogCode = b.activeCatalogCode,
	a.CrsMatchCatalogName = b.ActiveCatalogName,
	a.flagRecvdCampaign = 1
-- select a.*, b.activecatalogcode, b.activecatalogname
from staging.OrdAllctn_AllOrders_weekly a join
	#temp6 b on a.OrderID = b.OrderID
where a.FlagUnsourcedOrder = 1
and a.AssignedCode in (0,45)
and a.CrsMatchCatalogCode is null
and b.FinalRank = 1




-- Reassign identified course level match
drop table staging.OrdAllctn_BudCodeAssign_weekly_Crs

select distinct b.Cpn_ChannelID, b.Cpn_Country,
	b.Cpn_Channel, 
	b.Cpn_PromotionTypeID,
	b.Cpn_PromotionType,
	b.Cpn_CampaignID,
	b.Cpn_CampaignName,
	 a.*
Into staging.OrdAllctn_BudCodeAssign_weekly_Crs
from staging.OrdAllctn_AllOrders_weekly a join
     (select distinct Catalogcode, MD_Country as Cpn_Country,
		ChannelID as Cpn_ChannelID,
		MD_Channel as Cpn_Channel,
		MD_PromotionTypeID Cpn_PromotionTypeID, MD_PromotionType Cpn_PromotionType,
		MD_CampaignID Cpn_CampaignID, MD_CampaignName Cpn_CampaignName
      from Mapping.vwAdcodesAll) b on a.CrsMatchCatalogCode = b.catalogcode	
									and a.BillingCountryCode = b.Cpn_Country										
where a.FlagUnsourcedOrder = 1	

select top 10 * from staging.OrdAllctn_BudCodeAssign_weekly_Crs


update a
set a.Asn_CatalogCode = b.CrsMatchCatalogCode,
	a.Asn_CatalogName = b.CrsMatchCatalogName,
	a.AssignedCode = b.CrsMatchCatalogCode,
	a.AssignedName = b.CrsMatchCatalogName,
	a.AssignReason = 'Mail_CourseMatch',
	a.Asn_ChannelID = b.Cpn_ChannelID,
	a.Asn_Channel = b.Cpn_Channel,
	a.Asn_PromotionTypeID = b.Cpn_PromotionTypeID,
	a.Asn_PromotionType = b.Cpn_PromotionType,
	a.Asn_CampaignID = b.Cpn_CampaignID,
	a.Asn_CampaignName = b.Cpn_CampaignName,
	a.Asn_Country = b.Cpn_Country
-- select *
from staging.OrdAllctn_AllOrders_weekly a join
	staging.OrdAllctn_BudCodeAssign_weekly_Crs b on a.OrderID = b.OrderID
where a.FlagUnsourcedOrder = 1	
and a.flagrecvdcampaign = 1
and a.AssignedCode in (0,45)



select FlagUnsourcedOrder, AssignReason, COUNT(OrderID) Orders
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
group by FlagUnsourcedOrder, AssignReason
order by 1,2

select FlagUnsourcedOrder, AssignReason, Asn_CatalogCode, Asn_CatalogName, COUNT(OrderID) Orders
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 1
group by FlagUnsourcedOrder, AssignReason, Asn_CatalogCode, Asn_CatalogName
order by 1,2,3




-------------------------- -------------------------- -------------------------- 
--- Allocate Sales based on Course purchased and Mail match for reactivation mailings
-------------------------- -------------------------- -------------------------- 

-- For Uncoded sales, try to allocate based on courses in the order.
-- Build Swamp Campaigns table
-- select * from staging.OrdAllctn_ActiveHouseCampaigns_weekly_Swamp

drop table staging.OrdAllctn_ActiveHouseCampaigns_weekly_Swamp

select *
into staging.OrdAllctn_ActiveHouseCampaigns_weekly_Swamp
from DataWarehouse.Mapping.vwAdcodesAll
where StopDate >= @ForecastWeekStart 
and StartDate <= @ForecastWeekSaturday
and MD_Channel in ('House Mailings')
and MD_PromotionType in ('House Mailings: Magnificent 7 Reactivation','House Mailings: Catalog Reactivation','House Mailings: Magalog Reactivation')
and MD_CampaignID <> 1234 -- Based on Joe P's request to remove best customers from allocation		
and MD_CampaignName not like '%Best Customer%'-- Based on Joe P's request to remove best customers from allocation
	

drop table staging.OrdAllctn_ActiveHouseCampaigns_weekly_SwampHistory


select a.*
into staging.OrdAllctn_ActiveHouseCampaigns_weekly_SwampHistory
from DataWarehouse.Archive.MailhistoryCurrentYear a join
	staging.OrdAllctn_ActiveHouseCampaigns_weekly_Swamp b on a.AdCode = b.AdCode
	
	
-- 3826132
select COUNT(*) from staging.OrdAllctn_ActiveHouseCampaigns_weekly_SwampHistory

delete from staging.OrdAllctn_ActiveHouseCampaigns_weekly_SwampHistory
where FlagHoldOut = 1
-- (0 row(s) affected)


-- Get customers who received these mailings
drop table staging.OrdAllctn_ActiveHouseCampaignRecipient_weekly_SMP

select a.*
into staging.OrdAllctn_ActiveHouseCampaignRecipient_weekly_SMP
from staging.OrdAllctn_ActiveHouseCampaigns_weekly_SwampHistory a join
	staging.OrdAllctn_AllOrders_weekly b on a.CustomerID = b.CustomerID



--- Course level 

-- Get Items level information
--drop table #TempSwamp
select b.*,
	a.CourseID, a.BundleID, a.StockItemID,
	a.SalesPrice
into #TempSwamp
from DataWarehouse.Marketing.DMPurchaseOrderItems a join
	staging.OrdAllctn_AllOrders_weekly b on a.OrderID = b.OrderID
where b.FlagUnsourcedOrder = 1	
and b.assignReason is null





--drop table #TempSwamp2

select distinct a.*,
	CONVERT(int,0) as NumActiveCampaigns,
	b.catalogCode as ActiveCatalogCode,
	b.catalogName as  ActiveCatalogName,
	CONVERT(int,0) as FlagReceivedMail
into #TempSwamp2	
from #TempSwamp a join
	(select distinct c.*, b.UserStockItemID, b.UnitCurrency
	from DataWarehouse.Staging.MktPricingMatrix b join
	DataWarehouse.staging.OrdAllctn_ActiveHouseCampaigns_weekly_Swamp c on b.CatalogCode = c.CatalogCode)b 
												on a.StockItemID = b.UserStockItemID 
												and a.BillingCountryCode = b.MD_Country
												and a.DateOrdered between b.StartDate and b.StopDate
												


select top 10 * from #TempSwamp2

-- update FlagReceivedMail
--select * from 	staging.OrdAllctn_ActiveHouseCampaigns_weekly_SwampHistory 
 
-- Now see if customer received that mail file
update a
set FlagRecvdCampaign = 1
-- select a.* --distinct a.orderid
from #TempSwamp2 a join
	(select distinct A.customerID, b.CatalogCode, b.StartDate, b.StopDate
	from 	staging.OrdAllctn_ActiveHouseCampaigns_weekly_SwampHistory a join
			DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode)b on a.CustomerID = b.CustomerID
											and a.ActiveCatalogCode = b.CatalogCode
											and a.DateOrdered between b.StartDate and b.StopDate
where FlagUnsourcedOrder = 1


select top 10  * from #TempSwamp2
where FlagRecvdCampaign = 1

-- see how many
--drop table #TempSwamp3

select distinct OrderID, ActiveCatalogCode, ActiveCatalogName
into #TempSwamp3
from #TempSwamp2 
where FlagRecvdCampaign = 1
order by 1,2

select orderid from #TempSwamp3
group by orderid
having COUNT(activecatalogcode) = 1

select * from #TempSwamp3
where orderid in (select orderid from #TempSwamp3
					group by orderid
					having COUNT(activecatalogcode) > 1)
order by 1,2					


-- Update assigned code
--drop table #TempSwamp4

select * 
into #TempSwamp4
from #TempSwamp3
where orderid in (select orderid from #TempSwamp3
					group by orderid
					having COUNT(activecatalogcode) = 1)
order by 1,2	

select top 10 * from #TempSwamp4


-- FOR MULTIS
--drop table #TempSwamp5

select *, case when MD_PromotionTypeID = 2 then 1
				when MD_PromotionTypeID = 7 then 2
				when MD_PromotionTypeID = 5 then 3
				else 0
			end as Rank
into #TempSwamp5
from #TempSwamp3 a join
	(select distinct catalogcode, MD_CampaignID, MD_CampaignDesc, MD_PromotionTypeID, MD_PromotionType,
		StartDate
	from DataWarehouse.Mapping.vwAdcodesAll) b on a.ActiveCatalogCode = b.CatalogCode
where orderid in (select orderid from #TempSwamp3
					group by orderid
					having COUNT(activecatalogcode) > 1)
order by 1,2	

select top 10 * from #TempSwamp5

--drop table #TempSwamp6
SELECT *,
	 rank() over(partition by orderID order by rank, StartDate desc, catalogcode) as FinalRank  -- PR 1/20/2014 changed to do sorting by startdate desc
into #TempSwamp6
from #TempSwamp5


select top 10 * from #TempSwamp6


--select * from staging.OrdAllctn_AllOrders_weekly			


update a
set a.CrsMatchCatalogCode = b.activeCatalogCode,
	a.CrsMatchCatalogName = b.ActiveCatalogName,
	a.flagRecvdCampaign = 1
-- select a.*, b.activecatalogcode, b.activecatalogname
from staging.OrdAllctn_AllOrders_weekly a join
	#TempSwamp4 b on a.OrderID = b.OrderID
where a.FlagUnsourcedOrder = 1


update a
set a.CrsMatchCatalogCode = b.activeCatalogCode,
	a.CrsMatchCatalogName = b.ActiveCatalogName,
	a.flagRecvdCampaign = 1
-- select a.*, b.activecatalogcode, b.activecatalogname
from staging.OrdAllctn_AllOrders_weekly a join
	#TempSwamp6 b on a.OrderID = b.OrderID
where a.FlagUnsourcedOrder = 1
and b.FinalRank = 1


-- Reassign identified course level match
drop table staging.OrdAllctn_BudCodeAssign_weekly_CrsSwamp

select distinct b.Cpn_ChannelID, b.Cpn_Country,
	b.Cpn_Channel, 
	b.Cpn_PromotionTypeID,
	b.Cpn_PromotionType,
	b.Cpn_CampaignID,
	b.Cpn_CampaignName,
	 a.*
Into staging.OrdAllctn_BudCodeAssign_weekly_CrsSwamp
from staging.OrdAllctn_AllOrders_weekly a join
     (select distinct Catalogcode, md_Country as Cpn_Country,
		ChannelID as Cpn_ChannelID,
		MD_Channel as Cpn_Channel,
		MD_PromotionTypeID Cpn_PromotionTypeID, MD_PromotionType Cpn_PromotionType,
		MD_CampaignID Cpn_CampaignID, MD_CampaignName Cpn_CampaignName
      from Mapping.vwAdcodesAll) b on a.CrsMatchCatalogCode = b.catalogcode
								and a.BillingCountryCode = b.Cpn_Country											
where a.FlagUnsourcedOrder = 1	

-- select * from staging.OrdAllctn_BudCodeAssign_weekly_CrsSwamp


update a
set a.Asn_CatalogCode = b.CrsMatchCatalogCode,
	a.Asn_CatalogName = b.CrsMatchCatalogName,
	a.AssignedCode = b.CrsMatchCatalogCode,
	a.AssignedName = b.CrsMatchCatalogName,
	a.AssignReason = 'Mail_CourseMatch_React',
	a.Asn_ChannelID = b.Cpn_ChannelID,
	a.Asn_Channel = b.Cpn_Channel,
	a.Asn_PromotionTypeID = b.Cpn_PromotionTypeID,
	a.Asn_PromotionType = b.Cpn_PromotionType,
	a.Asn_CampaignID = b.Cpn_CampaignID,
	a.Asn_CampaignName = b.Cpn_CampaignName,
	a.Asn_Country = b.cpn_Country
-- select *
from staging.OrdAllctn_AllOrders_weekly a join
	staging.OrdAllctn_BudCodeAssign_weekly_CrsSwamp b on a.OrderID = b.OrderID
where a.FlagUnsourcedOrder = 1	
and a.flagrecvdcampaign = 1
and a.AssignedCode in (0,45)



select FlagUnsourcedOrder, AssignReason, COUNT(OrderID) Orders
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
group by FlagUnsourcedOrder, AssignReason
order by 1,2


select FlagUnsourcedOrder, AssignReason, Asn_CatalogCode, Asn_CatalogName, COUNT(OrderID) Orders
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 1
group by FlagUnsourcedOrder, AssignReason, Asn_CatalogCode, Asn_CatalogName
order by 1,2



-- How is there 100% match??
-------------------------- -------------------------- -------------------------- 
--- Allocate rest to unallocated buckets
-------------------------- -------------------------- -------------------------- 

select count(*)
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where AssignReason is null
and FlagNewCustomer = 1 
and FlagUnsourcedOrder = 1
-- 1573

select * from  DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where asn_catalogcode = 146

update DataWarehouse.staging.OrdAllctn_AllOrders_weekly
set Asn_Catalogcode = 999,
	Asn_CatalogName = 'Unallocated Prospect Campaigns',
	AssignedCode = 999,
	AssignedName = 'Unallocated Prospect Campaigns',
	AssignReason = 'Unallocated Prospect Campaigns',
	Asn_ChannelID = 999,
	Asn_Channel = 'Unallocated Prospect Campaigns'
where AssignReason is null
and FlagNewCustomer = 1 
and FlagUnsourcedOrder = 1



select FlagUnsourcedOrder, AssignReason, COUNT(OrderID)
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
group by FlagUnsourcedOrder, AssignReason
order by 1,2
/*
FlagUnsourcedOrder AssignReason                                       
------------------ -------------------------------------------------- -----------
0                  NULL                                               11233
0                  Expired Emails                                     12
0                  Expired House DirectMail                           115
0                  Expired Prospect DirectMail                        62
1                  NULL                                               496
1                  Left in Paid Search: Brand                         330
1                  Mail_BundleMatch                                   76
1                  Mail_CourseMatch                                   1221
1                  Mail_CourseMatch_React                             77
1                  Unallocated Prospect Campaigns                     390

(10 row(s) affected)
*/


-- House campaigns
select count(*)
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where AssignReason is null
and FlagNewCustomer = 0 
and FlagUnsourcedOrder = 1
-- 1693

update DataWarehouse.staging.OrdAllctn_AllOrders_weekly
set Asn_CatalogCode = 998,
	Asn_CatalogName = 'Unallocated House Campaigns',
	AssignedCode = 998,
	AssignedName = 'Unallocated House Campaigns',
	AssignReason = 'Unallocated House Campaigns',
	Asn_ChannelID = 998,
	Asn_Channel = 'Unallocated House Campaigns'
where AssignReason is null
and FlagNewCustomer = 0 
and FlagUnsourcedOrder = 1


select FlagUnsourcedOrder, AssignReason, COUNT(OrderID)
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
group by FlagUnsourcedOrder, AssignReason
order by 1,2

/*
FlagUnsourcedOrder AssignReason                                       
------------------ -------------------------------------------------- -----------
0                  NULL                                               11233
0                  Expired Emails                                     12
0                  Expired House DirectMail                           115
0                  Expired Prospect DirectMail                        62
1                  Left in Paid Search: Brand                         330
1                  Mail_BundleMatch                                   76
1                  Mail_CourseMatch                                   1221
1                  Mail_CourseMatch_React                             77
1                  Unallocated House Campaigns                        496
1                  Unallocated Prospect Campaigns                     390

(10 row(s) affected)

*/

select FlagUnsourcedOrder, AssignReason, Asn_CatalogCode, Asn_CatalogName, COUNT(OrderID)
from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 1
group by FlagUnsourcedOrder, AssignReason, Asn_CatalogCode, Asn_CatalogName
order by 1,2,3

select top 10  * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where assignreason like 'left in %'
and flagnewcustomer = 1

-------------------------- -------------------------- -------------------------- 
--- Update Final assignments depending on channels/promotions/campaigns
-------------------------- -------------------------- -------------------------- 

-- 5/15/2014
--- Now update Asn_Catalogcode and Name based on rules
update DataWarehouse.staging.OrdAllctn_AllOrders_weekly
set Asn_CatalogCode = asn_ChannelID,
	Asn_CatalogName = Asn_Channel + '_' + Asn_PriceType
-- 	select * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 0
and asn_channelID = 4
and asn_catalogname is null

update DataWarehouse.staging.OrdAllctn_AllOrders_weekly
set Asn_CatalogCode = asn_ChannelID,
	Asn_CatalogName = Asn_Channel
-- 	select * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 0
and (asn_channelID in (3,5,13,14,18,19,20,47,48,8,15,45,43) or asn_Promotiontypeid in (47,49))
and asn_catalogname is null


update DataWarehouse.staging.OrdAllctn_AllOrders_weekly
set Asn_CatalogCode = asn_campaignID,
	Asn_CatalogName = Asn_CampaignName
-- 	select * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 0
and (asn_channelID in (9) or asn_campaignID in (1063,824,1058))
and asn_catalogName is null

update DataWarehouse.staging.OrdAllctn_AllOrders_weekly
set Asn_CatalogCode = asn_promotiontypeID,
	Asn_CatalogName = Asn_PromotionType
-- 	select * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 0
and (asn_promotiontypeid in (11,12,13,15,94,96,110,48,156) or (asn_channelID in (11,12) and asn_campaignID not in (1063,824,1058)))
and asn_catalogName is null

update DataWarehouse.staging.OrdAllctn_AllOrders_weekly
set Asn_CatalogCode = asn_campaignID,
	Asn_CatalogName = Asn_CampaignName
-- 	select * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 0
and asn_channelID in (1,2,6)
and asn_promotiontypeid in (1,2,3,4,5,6,7,8,9,10,14,17,16,101,103,18,19,20,21,155)
and asn_catalogName is null



update DataWarehouse.staging.OrdAllctn_AllOrders_weekly
set Asn_CatalogCode = asn_campaignID,
	Asn_CatalogName = Asn_CampaignName
-- 	select * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 0
and (asn_channelID in (9) or asn_campaignID in (1063,824,1058))

update DataWarehouse.staging.OrdAllctn_AllOrders_weekly
set Asn_CatalogCode = Asn_CampaignID,
	Asn_CatalogName = Asn_CampaignName
-- 	select * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where FlagUnsourcedOrder = 1
and assignreason like 'Mail%'

select top 10 * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where Asn_ChannelID is null

select top 10 * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly
where asn_catalogName is null

-- Update Format level inforamtion

select top 10 * from DataWarehouse.staging.OrdAllctn_AllOrders_weekly

--select * from Staging.vworderitems
-------------------------- -------------------------- -------------------------- 
--- Get Format level information
-------------------------- -------------------------- -------------------------- 

--drop table #tempFormats

select a.OrderID, 
	convert(varchar(15),replace(c.MediaTypeID,' ','')) MediaTypeID, b.SalesPrice, b.Quantity, d.CourseParts,
	(b.Salesprice * b.Quantity) Sales,
	(b.Quantity * d.courseParts) as Parts
into #tempFormats		
from staging.OrdAllctn_AllOrders_weekly a
	join DataWarehouse.Staging.vwOrderItems b on convert(varchar, a.OrderID) =convert(varchar, b.OrderID)
	join DataWarehouse.staging.InvItem c on b.StockItemID = c.StockItemID					
	join DataWarehouse.staging.MktCourse d on c.CourseID = d.CourseID	
	join DataWarehouse.Staging.OrderPayments e on a.OrderID = e.OrderID and e.status in (0,1,3,4) -- DAX	
where b.stockitemid like '[PD][ACVDT]%'	
and b.OrderID not like 'r%';

select top 10 * from #tempFormats	


-- drop table #tempFormatsAggrgt

select Orderid, MediaTypeID, SUM(Sales) Sales, SUM(Parts) Parts
into #tempFormatsAggrgt
from #tempFormats
group by Orderid, MediaTypeID
	

select distinct mediatypeid
from #tempFormats

--update staging.OrdAllctn_AllOrders_weekly
--set CD_Parts = 0,
--	cd_sales = 0 
	
update a
set a.cd_sales = b.Sales,
	a.cd_Parts = b.Parts
from staging.OrdAllctn_AllOrders_weekly a join
	#tempFormatsAggrgt b on a.OrderID = b.OrderID
where b.MediaTypeID = 'CD'
	
--update staging.OrdAllctn_AllOrders_weekly
--set DVD_Parts = 0,
--	DVD_Sales = 0 
	
update a
set a.dvd_Sales = b.Sales,
	a.DVD_Parts = b.Parts
from staging.OrdAllctn_AllOrders_weekly a join
	#tempFormatsAggrgt b on a.OrderID = b.OrderID
where b.MediaTypeID = 'DVD'

--update staging.OrdAllctn_AllOrders_weekly
--set DownloadA_Parts = 0,
--	DownloadA_Sales = 0 
	
update a
set a.DownloadA_Sales = b.Sales,
	a.DownloadA_Parts = b.Parts
from staging.OrdAllctn_AllOrders_weekly a join
	#tempFormatsAggrgt b on a.OrderID = b.OrderID
where b.MediaTypeID = 'DownloadA'

--update staging.OrdAllctn_AllOrders_weekly
--set DownloadV_Parts = 0,
--	DownloadV_Sales = 0 
	
update a
set a.DownloadV_Sales = b.Sales,
	a.DownloadV_Parts = b.Parts
from staging.OrdAllctn_AllOrders_weekly a join
	#tempFormatsAggrgt b on a.OrderID = b.OrderID
where b.MediaTypeID = 'DownloadV'


--update staging.OrdAllctn_AllOrders_weekly
--set Transcript_Sales = 0,
--	Transcript_parts = 0 
	
update a
set a.Transcript_Sales = b.Sales,
	a.Transcript_parts = b.Parts
from staging.OrdAllctn_AllOrders_weekly a join
	#tempFormatsAggrgt b on a.OrderID = b.OrderID
where b.MediaTypeID = 'Transcript'

update a
set a.Transcript_sales = a.Transcript_sales + b.Sales,
	a.Transcript_Parts = a.Transcript_Parts + b.Parts
from staging.OrdAllctn_AllOrders_weekly a join
	#tempFormatsAggrgt b on a.OrderID = b.OrderID
where b.MediaTypeID = 'DownloadT'


-- update final sales with exchange rate
-- added on 6/2/2014
-- if you forgot to update the exchange rate in the beginning...

select distinct currencyCode, Exchangerate
from staging.OrdAllctn_AllOrders_weekly


--update staging.OrdAllctn_AllOrders_weekly
--set ExchangeRate = 	case when CurrencyCode = 'GBP' then @GBP
--						when CurrencyCode = 'AUD' then @AUD  
--						else 1
--					end

-------------------------- -------------------------- -------------------------- 
--- Apply exchange rates
-------------------------- -------------------------- -------------------------- 
update staging.OrdAllctn_AllOrders_weekly
set NetOrderAmountDllrs = NetOrderAmount * ExchangeRate,
	CD_SalesDllrs = CD_Sales * ExchangeRate,
	DVD_SalesDllrs = DVD_Sales * ExchangeRate,
	DownloadA_SalesDllrs = DownloadA_Sales * ExchangeRate,
	DownloadV_SalesDllrs = DownloadV_Sales * ExchangeRate,
	Transcript_SalesDllrs = Transcript_Sales * ExchangeRate,
	TaxDllrs = Tax * ExchangeRate

-------------------------- -------------------------- -------------------------- 
--- Create a summary table for weekly report...
-------------------------- -------------------------- -------------------------- 


select forecastweek, count(*)
from Marketing.OrdAllctn_WeeklySummary
group by forecastweek
order by 1 desc

delete from  Marketing.OrdAllctn_WeeklySummary where forecastweek = @ForecastWeek

--if object_id('Marketing.OrdAllctn_WeeklySummaryTESTDEL') is not null
--drop table Marketing.OrdAllctn_WeeklySummaryTESTDEL

insert into Marketing.OrdAllctn_WeeklySummary
select cast(FromDate as DATEtime) FromDate, 
	cast(ToDate as DATEtime) ToDate, 
	cast(ForecastWeek as DATEtime) ForecastWeek,
	YearOrdered, MonthOrdered, WeekOfOrder, 
	FlagCountry, 
	FlagUnsourcedOrder, 
	AdCode, AdcodeName,
	CatalogCode, CatalogName, 
	MD_CountryID, MD_Country, 
	MD_AudienceID, MD_Audience, 
	MD_ChannelID, MD_Channel,
	MD_PromotionTypeID, MD_PromotionType, 
	MD_CampaignID, MD_CampaignName,
	MD_Year, MD_PriceTypeID, MD_PriceType,
	Asn_CountryID, Asn_Country, 
	Asn_AudienceID, Asn_Audience, 
	Asn_ChannelID, Asn_Channel, 
	Asn_PromotionTypeID, Asn_PromotionType, 
	Asn_CampaignID, Asn_CampaignName, 
	Asn_Year, Asn_PriceTypeID, Asn_PriceType, 
	Asn_CatalogCode, Asn_CatalogName,
	AssignedCode, AssignedName, AssignReason, 
	FlagNewCustomer, BillingCountryCode,
	CurrencyCode, ExchangeRate, 
	count(OrderID) Orders, 
	sum(NetOrderAmount) Sales,      
	sum(CD_Sales) CD_Sales, 
	sum(CD_Parts) CD_Parts, 
	sum(DVD_Sales) DVD_Sales, 
	sum(DVD_Parts) DVD_Parts, 
	sum(DownloadA_Sales) DownloadA_Sales, 
	sum(DownloadA_Parts) DownloadA_Parts, 
	sum(DownloadV_Sales) DownloadV_Sales, 
	sum(DownloadV_Parts) DownloadV_Parts, 
	sum(Transcript_Sales) Transcript_Sales, 
	sum(Transcript_Parts) Transcript_Parts, 
	sum(NetOrderAmountDllrs) SalesDollars,
	sum(Tax) Tax,
	sum(TaxDllrs) TaxDollars,
	sum(CD_SalesDllrs) CD_SalesDollars, 
	sum(DVD_SalesDllrs) DVD_SalesDollars, 
	sum(DownloadA_SalesDllrs) DownloadA_SalesDollars, 
	sum(DownloadV_SalesDllrs) DownloadV_SalesDollars, 
	sum(Transcript_SalesDllrs) Transcript_SalesDollars	
--into Marketing.OrdAllctn_WeeklySummaryTESTDEL
from staging.OrdAllctn_AllOrders_weekly
group by cast(FromDate as DATEtime) , 
	cast(ToDate as DATEtime) , 
	cast(ForecastWeek as DATEtime), 
	YearOrdered, MonthOrdered, WeekOfOrder, 
	FlagCountry, 
	FlagUnsourcedOrder, 
	AdCode, AdcodeName,
	CatalogCode, CatalogName, 
	MD_CountryID, MD_Country, 
	MD_AudienceID, MD_Audience, 
	MD_ChannelID, MD_Channel,
	MD_PromotionTypeID, MD_PromotionType, 
	MD_CampaignID, MD_CampaignName,
	MD_Year, MD_PriceTypeID, MD_PriceType,
	Asn_CountryID, Asn_Country, 
	Asn_AudienceID, Asn_Audience, 
	Asn_ChannelID, Asn_Channel, 
	Asn_PromotionTypeID, Asn_PromotionType, 
	Asn_CampaignID, Asn_CampaignName, 
	Asn_Year, Asn_PriceTypeID, Asn_PriceType, 
	Asn_CatalogCode, Asn_CatalogName,
	AssignedCode, AssignedName, AssignReason, 
	FlagNewCustomer, BillingCountryCode,
	CurrencyCode, ExchangeRate


-------------------------- -------------------------- -------------------------- 
--- Load archive table
-------------------------- -------------------------- -------------------------- 

insert into Archive.OrdAllctn_WeeklySummary_History
select *
from Marketing.OrdAllctn_WeeklySummary
where forecastweek = @ForecastWeek


select ForecastWeek, count(*) Counts
from  Marketing.OrdAllctn_WeeklySummary
group by ForecastWeek
order by 1 desc


END
GO
