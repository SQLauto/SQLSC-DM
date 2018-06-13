SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[SP_TGC_CoverPoll_bkp]
as

declare @samplesize int, @groupnum int, @tablenm varchar(255), @query1 nvarchar(4000), @query2 nvarchar(4000),@query3 nvarchar(4000),@query4 nvarchar(4000),@query5 nvarchar(4000),
@query6 nvarchar(4000),@query7 nvarchar(4000),@query8 nvarchar(4000),@query9 nvarchar(4000),@query10 nvarchar(4000),@query11 nvarchar(4000),@query12 nvarchar (4000)

select top 1 @samplesize =  [SampleSize] , @groupnum =  [NumOfGroups] from [DataWarehouse].[Mapping].[PollTemplate] where [BusinessUnit] = 'TGC' AND Surveytype ='Cover Poll'

select top 1 @tablenm = concat('rfm..',[BusinessUnit], '_' ,replace([Surveytype],' ','') , '_',replace(cast(getdate() as date),'-',''))from 
[DataWarehouse].[Mapping].[PollTemplate] where [BusinessUnit] = 'TGC' AND Surveytype ='Cover Poll'



set @tablenm = @tablenm
set @samplesize = @samplesize
set @groupnum = @groupnum


DECLARE @totalpopulation int
set @totalpopulation = @samplesize*@groupnum
declare @max int, @qry nvarchar(4000), @qry1 nvarchar(4000), @cnt int 
set @cnt = 0
set @max = max(@groupnum)
select @max
declare @tempgrp nvarchar(4000) = 'dbo.tempgrp'
 
--select * from [dbo].[Polling_MasterSuppression]
--select * from [dbo].[Polling_MasterOptOut]

set  @query1 = 'select  a.CustomerID,a.FirstName,a.LastName,c.MaxOpenDate,a.Frequency as SingleOrMulti,c.EmailAddress,0 as FlagSelected ,a.LastOrderDate,a.CountryCode,a.PreferredCategory2,a.MediaFormatPreference,a.OrderSourcePreference ,convert(int,0) as CustGroup into ' + @tablenm + 
' from DataWarehouse.Marketing.CampaignCustomerSignature a join (select distinct CustomerID from DataWarehouse.Marketing.DMPurchaseOrders where DateOrdered between  DATEADD(DAY, 1, EOMONTH(getdate(), -3)) and DATEADD(DAY, 1, EOMONTH(getdate(), -1)) )b on  a.CustomerID = b.CustomerID join (select * from DataWarehouse.Marketing.Vw_EPC_EmailPull where EmailFrequency = 1 and FlagDormantCustomer = 0) c on a.CustomerID = c.CustomerID where a.PublicLibrary = 0 and a.CountryCode = ''US'' and a.BuyerType = 4'

exec (@query1)

set @query2= 'delete a from ' +  @tablenm + ' a join
	DataWarehouse..Polling_MasterOptOut b on a.Emailaddress = b.EmailAddress'

exec (@query2)
set @query3 = 'delete a from ' +@tablenm +' a join
	DataWarehouse..Polling_MasterOptOut b on a.Emailaddress = b.EmailAddress2'

exec (@query3)
	
set @query4 ='delete a from '+@tablenm+' a join
	DataWarehouse..Polling_MasterOptOut b on a.CustomerID = b.CustomerID'
exec (@query4)
	
set @query5 ='delete a from ' + @tablenm + ' a join
	DataWarehouse..Polling_MasterSuppression b on a.CustomerID = b.CustomerID'
exec (@query5)
	-- remove customers who got last week's course poll

	-- remove customers pulled earlier this week.

	select Business, max(Pulldate)
	from datawarehouse.archive.RD_Polling_History
	group by Business
	
set @query6 = 'delete a from '+ @tablenm+' a join (select * from datawarehouse.archive.RD_Polling_History
	where Business = ''TGC'' and PullDate >= dateadd(day,-40,getdate())) b on a.CustomerID = b.CustomerID'
exec (@query6)

set @query7 ='delete a from '+ @tablenm+ ' a join
	(select * from datawarehouse.archive.RD_Polling_History where Business = ''TGC''
	and PullDate >= dateadd(day,-40,getdate()))b on a.Emailaddress = b.EmailAddress'
exec (@query7)



select @samplesize*@groupnum


set @query8= 'select * into #temp2 from ' + @tablenm

exec (@query8)




if OBJECT_ID('dbo.TempPoll') is not null   
drop table dbo.TempPoll
declare @temp3 varchar(50)
set @temp3	 = 'TempPoll'

set @query9='select a.CustomerID, min(MaxOpenDate) Maxopendate into ' + @temp3+ ' from '+ @tablenm +'  a join (select distinct customerid from '+  @tablenm + ' group by CustomerID having count(Emailaddress) > 1)B  ON A.CustomerID = b.CustomerID group by a.CustomerID'

exec (@query9)


 set @query10= 'delete a from ' + @tablenm + ' a join ' + @temp3 +' b ON A.CustomerID = b.CustomerID
				and a.MaxOpenDate = b.Maxopendate'

exec (@query10)


set @query12 = 'update a
set a.flagselected = 0,
	a.CustGroup = 0 from '  + @tablenm + ' a'

exec (@query12)

declare @avlsample int


  
SELECT  @avlsample =  SUM([Partitions].[rows])  
FROM rfm.sys.tables AS [Tables]
JOIN rfm.sys.partitions AS [Partitions]
ON [Tables].[object_id] = [Partitions].[object_id]
AND [Partitions].index_id IN ( 0, 1 )
 WHERE [Tables].name = substring(@tablenm,6,50)
GROUP BY SCHEMA_NAME(schema_id), [Tables].name
 
  select @avlsample 





set @qry = 'select distinct top  ' + cast(@samplesize as nvarchar(10)) + '  * into ' +  @tempgrp +' from ' +@tablenm + ' where FlagSelected = 0 order by newid()' 

set @qry1 ='update a set a.flagselected = 1, a.CustGroup = ' + cast(@cnt as nvarchar(10)) + ' from ' +  @tablenm + ' a join ' +  @tempgrp +' b on a.CustomerID = b.CustomerID' 


IF( @avlsample >= @totalpopulation )
BEGIN 

print('here')

select @qry

select @cnt
select @groupnum
select @qry
select @qry1
select @query12
print ('starts here')
Declare @sql nvarchar(max)
 SET @SQL = ' @cnt = @cnt + 1'
	



while @cnt <= @groupnum
begin

select ' starting counts'
 select cast(@cnt as nvarchar(10))
 select @groupnum
 select @samplesize
 if OBJECT_ID('dbo.tempgrp') is not null   
	drop table dbo.tempgrp

 --exec (@qry)
 --exec (@qry1)
 set @qry1= 'update a set a.flagselected = 1, a.CustGroup = ' + cast(@cnt as nvarchar(10)) + ' from ' +  @tablenm + ' a join ' +  @tempgrp +' b on a.CustomerID = b.CustomerID' 
 exec (@qry)
 exec (@qry1)
 select @qry
 select @qry1

	set @cnt = @cnt  +1 
	


end 

declare @qry3 nvarchar(4000) 

set @qry3 = ' delete from ' + @tablenm + '  where CustGroup = 0' 

exec (@qry3)


end






--delete from rfm..TGC_CoverPoll_2080326_del 
--where CustGroup = 0

	-- Final to excel - Main tab
	/*select 	 CustomerID
			,DataWarehouse.Staging.Proper(FirstName) FirstName 
			,DataWarehouse.Staging.Proper(LastName) LastName
			,MaxOpenDate
			,SingleOrMulti
			,EmailAddress
			,FlagSelected
			,LastOrderDate 
			,CountryCode
			,OrderSourcePreference
			,CustGroup
			,getdate() DatePulled
		from rfm..TGC_CoverPoll_2080326_del
	where FlagSelected = 1
	order by custgroup


--drop table datawarehouse.archive.RD_Polling_History

--select *
--into datawarehouse.archive.RD_Polling_History
--from datawarehouse.archive.RD_Polling_History_del


--drop table datawarehouse.archive.RD_Polling_History_del

select * from datawarehouse.archive.RD_Polling_History

select Business, PollType, PullDate, CustGroup, count(*)  
from datawarehouse.archive.RD_Polling_History
group by Business, PollType, PullDate, CustGroup
order by 1,2,3,4



select min(pulldate) from archive.RD_Polling_History

	-- Create History File

	insert into datawarehouse.archive.RD_Polling_History_del
	select convert(varchar(50),'TGC_CoverPoll_2080326_del') as TableName
		,convert(varchar(50),'Cover Poll') as PollType
		,convert(varchar(50),'TGC') as Business
		,convert(nvarchar(20),CustomerID) as CustomerID
		,Emailaddress
		,SingleOrMulti Frequency
		,convert(varchar(50),CountryCode) as CountryCode
		,CustGroup
		,null as TransactionType
		,null as CustStatusFlag
		,null as PaidFlag
		,cast(getdate() as date) as PullDate
		,PreferredCategory2
		,MediaFormatPreference
		,OrderSourcePreference  -- added this on 10/4 based on Rachelle's request

		--into datawarehouse.archive.RD_Polling_History_del
	from rfm..TGC_CoverPoll_2080326_del
	where CustGroup > 0

select TableName, PollType, Business, CustomerID, Emailaddress, Frequency, CountryCode, CustGroup, TransactionType, CustStatusFlag, PaidFlag, PullDate

from datawarehouse.archive.RD_Polling_History_del


*/





GO
