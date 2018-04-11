SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
      
      
CREATE Proc [dbo].[SP_Contact_DownStream_Historical] @Fullrefresh int = 1      
as      
BEGIN      
      
declare @InitialPurchaseYear int      
      
/* Complete Run for all year*/      
If @Fullrefresh = 1      
      
      
      
Begin       
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
truncate table DataWarehouse.Marketing.DMEmailContactDownStream      
truncate table DataWarehouse.Marketing.DMmailContactDownStream      
      
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
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2010 Eh2010 (nolock)      
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @InitialPurchaseYear between 0 and 3)      
union all      
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2011 Eh2011 (nolock)      
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @InitialPurchaseYear between 0 and 3)      
union all      
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2012 Eh2012 (nolock)      
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @InitialPurchaseYear between 0 and 3)      
union all      
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2013 Eh2013 (nolock)      
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @InitialPurchaseYear between 0 and 3)      
union all      
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2014 Eh2014 (nolock)      
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @InitialPurchaseYear between 0 and 3)      
union all      
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2015 Eh2015 (nolock)      
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @InitialPurchaseYear between 0 and 3)      
union all      
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2016 Eh2016 (nolock)      
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @InitialPurchaseYear between 0 and 3)      
union all      
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2017 Eh2017 (nolock)      
where FlagHoldOut = 0 and (DATEPART(YEAR,StartDate) - @InitialPurchaseYear between 0 and 3)      
union all      
select CustomerID,StartDate from DataWarehouse.Archive.EmailHistory2018 Eh2018 (nolock)      
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
select mh.customerid,mh.StartDate from DataWarehouse.Archive.MailingHistory mh (nolock)      
where mh.FlagHoldOut = 0      
) mh      
on cust.CustomerID = mh.CustomerID      
and DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) between 0 and 730      
group by cust.customerid,cust.IntlPurchaseDate      
--option (maxdop 4)      
      
--select * into DataWarehouse.Marketing.DMEmailContactDownStream  from #CustomerEmails      
insert into DataWarehouse.Marketing.DMEmailContactDownStream       
select *,getdate() from #CustomerEmails      
      
--select * into DataWarehouse.Marketing.DMmailContactDownStream  from #Customermails      
insert into DataWarehouse.Marketing.DMmailContactDownStream       
select *,getdate() from #Customermails      
      
      
update a        
set  processed = 1      
from #year a       
where processed = 0 and [YEAR] = @InitialPurchaseYear      
      
drop table #Customermails      
drop table #CustomerEmails      
drop table #CustomerInitialPurchase      
      
end      
      
END      
      
/*      
Else      
      
begin      
      
select       
      
select @InitialPurchasedate = DATEADD(mm,-26,getdate())      
      
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
--into #CustomerInitialPurchase      
from DataWarehouse.Marketing.DMCustomerStatic      
where IntlPurchaseDate >= @InitialPurchaseYear      
       
--alter table #CustomerInitialPurchase add primary key (customerid)      
      
select cust.customerid,cust.IntlPurchaseDate,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 30 then 1 else 0 end) as DS1moEmailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 60 then 1 else 0 end) as DS2moEmailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 90 then 1 else 0 end) as DS3moEmailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 180 then 1 else 0 end) as DS6moEmailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 360 then 1 else 0 end) as DS12moEmailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 540 then 1 else 0 end) as DS18moEmailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 730 then 1 else 0 end) as DS24moEmailContacts      
into #CustomerEmailsDelta      
from #CustomerInitialPurchase cust (nolock)      
left join(      
 select * from DataWarehouse.Archive.EmailHistory_      
) Eh (nolock)      
on cust.CustomerID = Eh.CustomerID      
and DATEDIFF(dd,cust.IntlPurchaseDate,eh.StartDate) <= 730      
where eh.FlagHoldOut = 0      
group by cust.customerid,cust.IntlPurchaseDate      
      
      
select cust.customerid,cust.IntlPurchaseDate,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 30 then 1 else 0 end) as DS1momailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 60 then 1 else 0 end) as DS2momailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 90 then 1 else 0 end) as DS3momailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 180 then 1 else 0 end) as DS6momailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 360 then 1 else 0 end) as DS12momailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 540 then 1 else 0 end) as DS18momailContacts,      
sum(case when DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 730 then 1 else 0 end) as DS24momailContacts      
into #CustomermailsDelta      
from #CustomerInitialPurchase cust (nolock)      
left join DataWarehouse.Archive.MailingHistory mh (nolock)      
on cust.CustomerID = mh.CustomerID      
and DATEDIFF(dd,cust.IntlPurchaseDate,mh.StartDate) <= 730      
where mh.FlagHoldOut = 0      
group by cust.customerid,cust.IntlPurchaseDate      
      
      
      
--Updates for any sent EMails in previous 26 month new customers      
update DS      
set ds.DS1moEmailContacts = cust.DS1moEmailContacts      
, ds.DS2moEmailContacts = cust.DS2moEmailContacts      
, ds.DS3moEmailContacts = cust.DS3moEmailContacts      
, ds.DS6moEmailContacts = cust.DS6moEmailContacts      
, ds.DS12moEmailContacts = cust.DS12moEmailContacts      
, ds.DS18moEmailContacts = cust.DS18moEmailContacts      
, ds.DS24moEmailContacts = cust.DS24moEmailContacts      
from #CustomerEmailsDelta cust      
inner join DataWarehouse.Marketing.DMEmailContactDownStream DS      
on cust.customerid = DS.customerid      
where ds.customerid is null      
      
      
--Any new Emails inserts      
insert into DataWarehouse.Marketing.DMEmailContactDownStream       
select * from #CustomerEmailsDelta cust      
left join DataWarehouse.Marketing.DMEmailContactDownStream DS      
on cust.customerid = DS.customerid      
where ds.customerid is null      
      
      
--Updates for any sent mailing in previous 26 month new customers      
update DS      
set ds.DS1momailContacts = cust.DS1momailContacts      
, ds.DS2momailContacts = cust.DS2momailContacts      
, ds.DS3momailContacts = cust.DS3momailContacts      
, ds.DS6momailContacts = cust.DS6momailContacts      
, ds.DS12momailContacts = cust.DS12momailContacts      
, ds.DS18momailContacts = cust.DS18momailContacts      
, ds.DS24momailContacts = cust.DS24momailContacts      
from #CustomermailsDelta cust      
inner join DataWarehouse.Marketing.DMmailContactDownStream DS      
on cust.customerid = DS.customerid      
where ds.customerid is null      
      
      
--Any new mailing inserts      
insert into DataWarehouse.Marketing.DMmailContactDownStream       
select * from #CustomermailsDelta cust      
left join DataWarehouse.Marketing.DMmailContactDownStream DS      
on cust.customerid = DS.customerid      
where ds.customerid is null      
      
      
end      
      
      
*/      
      
      
END       
      
     
GO
