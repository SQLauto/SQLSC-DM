SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
    
CREATE Proc [dbo].[SP_Contact_DownStream]  
as    
BEGIN    
    
declare @InitialPurchaseYear int    
    
/* Run Delta Email and Mail 2 year Downstream Contacts add customers in the last three years */    
   
    
--create table #year1 ([year] int identity(2010,1),processed bit default (0))    
/*    
--takes forever    
select [Year] , 0 as processed    
into #year    
From (    
select datepart(YEAR,StartDate) [Year] from DataWarehouse.Archive.MailingHistory mh (nolock)    
group by datepart(YEAR,StartDate)    
union     
select datepart(YEAR,StartDate) [Year] from DataWarehouse.Archive.EMailHistory mh (nolock)    
group by datepart(YEAR,StartDate)    
 ) a    
*/    
     	
	select distinct Year,0 as processed  
	into #year
	from Datawarehouse.mapping.date
	where Year>= year(getdate()) -2 and Year<=year(getdate()-1)

    select * from #year

-- Source table start with acquisions Datawarehouse.Marketing.DMCustomerStatic    
    
	while exists (select * from #year where processed = 0 )     
		begin    
    
		select top 1 @InitialPurchaseYear = [YEAR] from #year where processed = 0     
		order by 1 asc    
    
    
		select CustomerID,    
		  cast(IntlPurchaseDate as date) IntlPurchaseDate,    
		  convert(int,0)  DS1moMailContacts ,     
		  convert(int,0)  DS2moMailContacts ,    
		  convert(int,0)  DS3moMailContacts ,    
		  convert(int,0)  DS6moMailContacts ,     
		  convert(int,0)  DS12moMailContacts ,    
		  convert(int,0)  DS18moMailContacts ,    
		  convert(int,0)  DS24moMailContacts ,      
		  convert(int,0)  DS1moEmailContacts ,    
		  convert(int,0)  DS2moEmailContacts ,    
		  convert(int,0)  DS3moEmailContacts ,    
		  convert(int,0)  DS6moEmailContacts ,     
		  convert(int,0)  DS12moEmailContacts ,    
		  convert(int,0)  DS18moEmailContacts ,    
		  convert(int,0)  DS24moEmailContacts    
		into #CustomerInitialPurchase    
		from DataWarehouse.Marketing.DMCustomerStatic    
		where DATEPART(YEAR,IntlPurchaseDate)=@InitialPurchaseYear    


		/* Add Pk customerid */     
		alter table #CustomerInitialPurchase add primary key (customerid)    
    
		select cust.customerid,cust.IntlPurchaseDate,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 30 then 1 else 0 end) as DS1moEmailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 60 then 1 else 0 end) as DS2moEmailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 90 then 1 else 0 end) as DS3moEmailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 180 then 1 else 0 end) as DS6moEmailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 360 then 1 else 0 end) as DS12moEmailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 540 then 1 else 0 end) as DS18moEmailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 730 then 1 else 0 end) as DS24moEmailContacts    
		into #CustomerEmails    
		from #CustomerInitialPurchase cust (nolock)    
		left join     
		(    
		select CustomerID,StartDate from [Archive].[EmailhistoryCurrentYear] (nolock)    
		where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @InitialPurchaseYear between 0 and 3)    
		union all    
		select CustomerID,StartDate from [Archive].[EmailhistoryPrior1Year] (nolock)    
		where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @InitialPurchaseYear between 0 and 3)    
		union all    
		select CustomerID,StartDate from [Archive].[EmailhistoryPrior2Year] (nolock)    
		where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @InitialPurchaseYear between 0 and 3)    
 
		)EH    
		on cust.CustomerID = Eh.CustomerID    
		and DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) between 0 and 730    
		group by cust.customerid,cust.IntlPurchaseDate    
		--option (maxdop 4)    
  
		select cust.customerid,cust.IntlPurchaseDate,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 30 then 1 else 0 end) as DS1momailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 60 then 1 else 0 end) as DS2momailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 90 then 1 else 0 end) as DS3momailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 180 then 1 else 0 end) as DS6momailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 360 then 1 else 0 end) as DS12momailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 540 then 1 else 0 end) as DS18momailContacts,    
		sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 730 then 1 else 0 end) as DS24momailContacts    
		into #Customermails    
		from #CustomerInitialPurchase cust (nolock)    
		left join    
		(    
		select mh.customerid,mh.StartDate from [Archive].[MailhistoryCurrentYear] mh (nolock)    
		where mh.FlagHoldOut = 0   
		Union All
		select mh.customerid,mh.StartDate from [Archive].[MailhistoryPrior1Year] mh (nolock)    
		where mh.FlagHoldOut = 0   
		Union All
		select mh.customerid,mh.StartDate from [Archive].[MailhistoryPrior2Year] mh (nolock)    
		where mh.FlagHoldOut = 0   
		) mh    
		on cust.CustomerID = mh.CustomerID    
		and DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) between 0 and 730    
		group by cust.customerid,cust.IntlPurchaseDate    


		--select * into DataWarehouse.Marketing.DMEmailContactDownStream  from #CustomerEmails    

 

		Delete DS from DataWarehouse.Marketing.DMEmailContactDownStream DS
		join #CustomerEmails E
		on E.customerid = DS.customerid

		insert into DataWarehouse.Marketing.DMEmailContactDownStream     
		select *,getdate() from #CustomerEmails    
    
 
		Delete DS from DataWarehouse.Marketing.DMmailContactDownStream DS
		join #Customermails E
		on E.customerid = DS.customerid

		insert into DataWarehouse.Marketing.DMmailContactDownStream     
		select *,getdate() from #Customermails    
    
    
		update a      
		set  processed = 1    
		from #year a     
		where processed = 0 and [YEAR] = @InitialPurchaseYear    


		select @InitialPurchaseYear as 'Completed Year'
    
		drop table #Customermails    
		drop table #CustomerEmails    
		drop table #CustomerInitialPurchase    
    
		end    
    
    
    
    
END     
    
   
GO
