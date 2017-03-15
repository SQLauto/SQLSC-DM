SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Staging].[UpdateOSWDashboard] 
	@OSWYear int,
	@OSWType varchar(20),
	@catCodes varchar(250),
	@StartDate datetime,
	@EndDate Datetime = null
AS
-- Preethi Ramanujam    1/16/2013  Update OSW dashboard  -- NEW

-- Preethi Ramanujam    1/24/2013  Update OSW dashboard  -- add units and parts

-- Preethi Ramanujam    8/20/2014  Update demographics from WD table instead of Customer Overlay table.

	
begin

	DECLARE @Qry varchar(Max)
	
	set @EndDate = coalesce(@EndDate, getdate()) 

	if object_id('Staging.OSW_Current') is not null
		drop table Staging.OSW_Current

		
	set @Qry = 'select ' + convert(varchar,@OSWYear) + ' as Year, ''' +
		 @OSWType + ''' as OSW, /* CourseLive: 12/21/2012; InHome: 1/7/2013; ExpDate: 1/31/2013 */
		 convert(datetime,convert(varchar,d.DateOrdered,101)) as DateOrdered,
		 a.OrderSource, a.Adcode, a.AdcodeName,               
		 a.CatalogCode, a.CatalogName, 
		 a.FlagAudioVideo, a.FlagDigitalPhysical, a.BillingCountryCode,             
		 SUM(case when a.OrderID like ''RET%'' or a.NetOrderAmount is null then 0 else 1 end) as TotalOrders,            
		 SUM(NetOrderAmount) as TotalSales,
         SUM(Units) as TotalUnits, /* Added on 1/24/2013 as per business request */
         SUM(Parts) as TotalParts, /* Added on 1/24/2013 as per business request*/
         left(a.Gender,1) Gender,
		 a.IncomeDescription,
		 a.Education,
		 a.AgeBin, 
		 a.Region
	into   Datawarehouse.Staging.OSW_Current              
	from (select distinct convert(datetime,convert(varchar,DateOrdered,101)) as DateOrdered 
			from Marketing.DMPurchaseOrders) d         
	left join (select convert(datetime,convert(varchar,t11.DateOrdered,101)) as DateOrdered, 
					t11.OrderId, 
					t11.NetOrderAmount, 
					t11.OrderSource, 
					t11.TotalCourseQuantity as Units,  /* Added on 1/24/2013 as per business request */
					t11.TotalCourseParts as Parts,  /* Added on 1/24/2013 as per business request */
					t11.AdCode, 
					t11.FlagAudioVideo, t11.FlagDigitalPhysical, t11.BillingCountryCode,
					b.Name as AdCodeName, 
					c.CatalogCode, 
					c.Name as CatalogName,
					t14.Gender, 
					case when t16.time_group=1 then ''Eastern''
						when t16.time_group=2 then ''Central''
						when t16.time_group=3 then ''Mountain''
						when t16.time_group=4 then ''Pacific''
						when t16.time_group=5 then ''Alaskan''
						when t16.time_group=6 then ''International''
					end Region,
					t14.IncomeDescription,
					t14.Education,
					t11.AgeBin                 
			   from Marketing.DMPurchaseOrders t11    
			   join Staging.MktAdCodes b  on t11.Adcode = b.AdCode 
			   join Staging.MktCatalogCodes c  on b.CatalogCode = c.CatalogCode
			   -- left join Mapping.CustomerOverLay t14 on t11.CustomerID = t14.CustomerID
			   left join Mapping.CustomerOverLay_WD t14 on t11.CustomerID = t14.CustomerID
			   left join Marketing.CampaignCustomerSignature t15 on t11.CustomerID = t15.CustomerID
			   Left join Lstmgr.dbo.state_zone t16 on t16.State=t15.state
					where b.CatalogCode in (' + @catCodes + ')      
					and t11.OrderID not like ''R%'') a   on d.DateOrdered=a.DateOrdered  
	where   d.DateOrdered between ''' + convert(varchar,@StartDate,101) + ''' and ''' + CONVERT(varchar,@EndDate,101) +        
	''' group by convert(datetime,convert(varchar,d.DateOrdered,101)),                    
		 a.OrderSource, a.Adcode, a.AdcodeName,               
		 a.CatalogCode, a.CatalogName, 
		 a.FlagAudioVideo, a.FlagDigitalPhysical, a.BillingCountryCode,
		 a.Gender,
		 a.IncomeDescription,
		 a.Education,
		 a.AgeBin, 
		 a.Region'         

	print @Qry

	exec (@Qry)


	-- Delete catalogcodes from the base if they are in current
	delete a
	-- select a.*
	from Marketing.OSW_Dashboard a join
		(select distinct catalogcode
		from Staging.OSW_Current) b on a.CatalogCode = b.catalogcode

	-- Append current data into base table.
	insert into Marketing.OSW_Dashboard
	select * from Staging.OSW_Current

	drop table Staging.OSW_Current
	
end
GO
