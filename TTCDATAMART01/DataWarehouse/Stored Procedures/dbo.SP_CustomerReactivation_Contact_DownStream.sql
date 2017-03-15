SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
CREATE Proc [dbo].[SP_CustomerReactivation_Contact_DownStream] @Fullrefresh int = 1    
as    
BEGIN    
    
declare @ReActivationYear int    
    
/* Complete Run for all year*/    
If @Fullrefresh = 1    
    
Begin     
    
select * into #year    
from (select 2010 [Year],0 as processed Union    
select 2011 [Year],0 as processed Union    
select 2012 [Year],0 as processed Union    
select 2013 [Year],0 as processed Union    
select 2014 [Year],0 as processed Union    
select 2015 [Year],0 as processed Union    
select 2016 [Year],0 as processed Union    
select 2017 [Year],0 as processed Union    
select 2018 [Year],0 as processed Union    
select 2019 [Year],0 as processed Union    
select 2020 [Year],0 as processed    
--add more years here if needed    
) years    
    
delete from #year    
where [year] > datepart(year,GETDATE())    
    
    
--Truncate both the Downstrem tables    
truncate table DataWarehouse.Marketing.DMEmailCustomerReactivationContactDownStream    
truncate table DataWarehouse.Marketing.DMmailCustomerReactivationContactDownStream    
    
    
while exists (select * from #year where processed = 0 )     
begin    
    
select top 1 @ReActivationYear = [YEAR] from #year where processed = 0     
order by 1 asc    
    
    
select CustomerKey,CustomerID,    
  cast(DateOrdered as date) ReactivationDate,    
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
into #CustomerReActivation    
from DataWarehouse.Marketing.DMCustomerReActivation    
where DATEPART(YEAR,DateOrdered)=@ReActivationYear    
    
    
    
/* Add Pk customerid */     
--alter table #CustomerReActivation add primary key (customerid)    
    
select cust.CustomerKey,cust.customerid,cust.ReactivationDate,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,eh.StartDate) <= 30 then 1 else 0 end) as DS1moEmailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,eh.StartDate) <= 60 then 1 else 0 end) as DS2moEmailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,eh.StartDate) <= 90 then 1 else 0 end) as DS3moEmailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,eh.StartDate) <= 180 then 1 else 0 end) as DS6moEmailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,eh.StartDate) <= 360 then 1 else 0 end) as DS12moEmailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,eh.StartDate) <= 540 then 1 else 0 end) as DS18moEmailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,eh.StartDate) <= 730 then 1 else 0 end) as DS24moEmailContacts    
into #CustomerEmails    
from #CustomerReActivation cust (nolock)    
left join     
(    
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2010 Eh2010 (nolock)    
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @ReActivationYear between 0 and 3)    
union all    
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2011 Eh2011 (nolock)    
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @ReActivationYear between 0 and 3)    
union all    
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2012 Eh2012 (nolock)    
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @ReActivationYear between 0 and 3)    
union all    
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2013 Eh2013 (nolock)    
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @ReActivationYear between 0 and 3)    
union all    
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2014 Eh2014 (nolock)    
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @ReActivationYear between 0 and 3)    
union all    
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2015 Eh2015 (nolock)    
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @ReActivationYear between 0 and 3)    
union all    
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2016 Eh2016 (nolock)    
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @ReActivationYear between 0 and 3)  
)EH    
on cust.CustomerID = Eh.CustomerID    
and DATEDIFF(dd,cust.ReactivationDate,eh.StartDate) between 0 and 730    
group by cust.CustomerKey,cust.customerid,cust.ReactivationDate    
--option (maxdop 4)    
    
select cust.CustomerKey,cust.customerid,cust.ReactivationDate,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,mh.StartDate) <= 30 then 1 else 0 end) as DS1momailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,mh.StartDate) <= 60 then 1 else 0 end) as DS2momailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,mh.StartDate) <= 90 then 1 else 0 end) as DS3momailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,mh.StartDate) <= 180 then 1 else 0 end) as DS6momailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,mh.StartDate) <= 360 then 1 else 0 end) as DS12momailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,mh.StartDate) <= 540 then 1 else 0 end) as DS18momailContacts,    
sum(case when DATEDIFF(dd,cust.ReactivationDate,mh.StartDate) <= 730 then 1 else 0 end) as DS24momailContacts    
into #Customermails    
from #CustomerReActivation cust (nolock)    
left join    
(    
select mh.customerid,mh.StartDate from DataWarehouse.Archive.MailingHistory mh (nolock)    
where mh.FlagHoldOut = 0    
) mh    
on cust.CustomerID = mh.CustomerID    
and DATEDIFF(dd,cust.ReactivationDate,mh.StartDate) between 0 and 730    
group by cust.CustomerKey,cust.customerid,cust.ReactivationDate    
    
    
    
insert into DataWarehouse.Marketing.DMEmailCustomerReactivationContactDownStream     
select * from #CustomerEmails    
    
insert into DataWarehouse.Marketing.DMmailCustomerReactivationContactDownStream     
select * from #Customermails    
    
    
update a      
set  processed = 1    
from #year a     
where processed = 0 and [YEAR] = @ReActivationYear    
    
drop table #Customermails    
drop table #CustomerEmails    
drop table #CustomerReActivation    
    
select @ReActivationYear '@ReActivationYear'    
    
end    
    
END    
    
    
--Load DownStream Monthly    
Exec [dbo].[LoadDMCustomerReActivationDownStreamMonthlyNew]    
    
END     
    
    
GO
