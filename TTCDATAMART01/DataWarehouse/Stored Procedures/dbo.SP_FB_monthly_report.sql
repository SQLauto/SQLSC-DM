SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_FB_monthly_report]
as
Begin

-- PR 5/18/2016

/*
From: Allison Lesser 
Sent: Tuesday, May 17, 2016 10:11 AM
To: Preethi Ramanujam
Cc: Dave Sanders; Joseph Peckl
Subject: Monthly List updates for Facebook

Hi Preethi –
It’s that time of month! ;) We had decided last month that you would provide us monthly list updates for Facebook on the 15th, which would include the following audience files. 

Since we just updated the Plus files, let’s update those in June unless Joe or Dave feel there’s a need to update earlier. 

Keep us posted once they are saved on the network. Thank you!

Allison


From: Allison Lesser 
Sent: Friday, April 15, 2016 12:03 PM
To: Joseph Peckl; Preethi Ramanujam; Dave Sanders; Lisa Simpson
Subject: RE: Custom segments for Facebook targeting

Thanks for meeting just now! Here’s a summary of the audience lists that we will update every 30 days, starting on the date that works for Preethi next week. Dave and Julie will upload these, and we’ll work with Big Lens on ensuring they are uploaded to t
he correct campaign.

-	16 TGC segments
-	Plus Subscribers (we will use this to suppress all campaigns and build a look-a-like)
-	Plus Registrations (registered with email but did not subscribers)
-	Plus cancels
-	Plus beta users who did not subscribe (beta users were given the service for free)

Preethi – keep me posted on timing, and that would be great if you can also send the slide with friendly names. 

Thanks!
Allison
*/

-- drop table Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
 if object_id ('staging.FaceBook_TGCPlusTest_AllCustWithEmails') is not null
 Drop table staging.FaceBook_TGCPlusTest_AllCustWithEmails

select a.Subscribed, 
		b.CountryCode,									
	case when (a.HardBounce + a.SoftBounce + a.Blacklist) > 0 then 1								
		else 0 end as BounceFlag,							
		b.CustomerSegmentFnl,							
		a.CustomerID,
		a.Email,
		CONVERT(int,null) as CustomerSegmentPriority,
		convert(varchar(20),null) as CustType,
		case when right(a.customerid,1) in (8,9,0) then convert(varchar(20),'Holdout') 
			else convert(varchar(20),'Test') 
		end as CustGroup,
		convert(varchar(50),null) as CustomerSegmentFnlFB,
		convert(varchar(50),null) as CustSegComboForRNDMZ
into Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails		
from DataWarehouse.Marketing.epc_preference a									
	left join	DataWarehouse.Marketing.CampaignCustomerSignature b on a.CustomerID = b.CustomerID							
where b.CountryCode = 'US'									
and b.PublicLibrary = 0		
and isnull(a.Email,'') <> ''

--select custgroup, count(*) from  Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails		
--group by custgroup

-- Create one column with combination to avoid multiple stratification

update Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
set CustomerSegmentFnl = REPLACE(CustomerSegmentFnl,' ','')

update Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
set CustomerSegmentFnlFB = case when CustomerSegmentFnl in ('Active_Multi','Active_Single', 
									'NewToFile_Single','Inactive_Multi',
									'Inactive_Single','DeepInactive_Multi','DeepInactive_Single') then CustomerSegmentFnl
									else 'Rest'
								end	
								
update Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
set CustSegComboForRNDMZ = null,CustomerSegmentPriority = null
 
update Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
set CustSegComboForRNDMZ = convert(varchar,subscribed) + '_' + convert(varchar,BounceFlag) + '_' + isnull(CustomerSegmentFnlFB,'')


--select distinct CustomerSegmentFnl, CustomerSegmentFnlFB, CustSegComboForRNDMZ
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
--order by 2

--select top 100 * 
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails

update Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
set CustType = case when Subscribed = 1  and BounceFlag = 0 then 'Emailable'
					else 'Non_Emailable' end
				
--select Subscribed, BounceFlag, CustType, CustGroup, COUNT(*)
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
--group by Subscribed, BounceFlag, CustType, CustGroup
--order by Subscribed, BounceFlag, CustType, CustGroup
	
--select distinct CustomerSegmentFnl
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
								
--- update priority.. so, we do not include same customer with different customerIDs and same email
-- to different groups..

--update 	Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
--set CustomerSegmentPriority = null

update 	Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
set CustomerSegmentPriority = case when CustomerSegmentFnlFB = 'Active_Multi' then 1
									when CustomerSegmentFnlFB = 'Active_Single' then 2
									when CustomerSegmentFnlFB = 'NewToFile_Single' then 3
									when CustomerSegmentFnlFB = 'Inactive_Multi' then 4
									when CustomerSegmentFnlFB = 'Inactive_Single' then 5	
									when CustomerSegmentFnlFB = 'DeepInactive_Multi' then 6
									when CustomerSegmentFnlFB like 'DeepInactive_Single' then 7
									else 8
								end


	
--select CustomerSegmentFnl, CustomerSegmentFnlFB, CustSegComboForRNDMZ, CustomerSegmentPriority, COUNT(*)
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
--group by CustomerSegmentFnl, CustomerSegmentFnlFB, CustSegComboForRNDMZ, CustomerSegmentPriority
--order by CustomerSegmentFnl, CustomerSegmentFnlFB, CustSegComboForRNDMZ, CustomerSegmentPriority
	
--select CustSegComboForRNDMZ, CustomerSegmentPriority, COUNT(*)
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
--group by CustSegComboForRNDMZ, CustomerSegmentPriority
--order by 2,1

-- create table for randomization

--select len('FaceBook_TGCP20160518RND')

---- drop table #temp

--select customerid, MIN(CustomerSegmentPriority) as CustomerSegmentPriority
--into #Temp
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
--group by CustomerID
---- (2067902 row(s) affected)


--select distinct b.*
--into Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsDedupe
--from #Temp a join
--	 Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails b on a.CustomerID = b.CustomerID
--														and a.CustomerSegmentPriority = b.CustomerSegmentPriority

--select count(*) from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails

--drop table Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsDedupe

---- drop table rfm..FaceBook_TGCP20160518RND

--select distinct a.CustomerID, a.CustomerSegmentPriority, b.CustSegComboForRNDMZ as ComboID, b.CustGroup
--into rfm..FaceBook_TGCP20160518RND
--from #Temp a join
--	 Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails b on a.CustomerID = b.CustomerID
--														and a.CustomerSegmentPriority = b.CustomerSegmentPriority
---- (2134220 row(s) affected)

--select 2134220.0 * .3  -- 30% holdout
---- 640266.00

---- drop table rfm..FaceBook_TGCP20160518RNDFDel

---- SAS code -- libname ecamp ODBC DSN = ColoSql01  schema = dbo qualifier = LstMgr insertbuff = 32767 bcp=yes;

--options compress=yes obs=max;
--libname ecamp ODBC DSN = TTCDataMart01  schema = dbo qualifier = rfm insertbuff = 32767 bcp=yes;

--proc sort data=ecamp.FaceBook_TGCP20160518RND out=RANDSORT;
--by comboid;
--run;

--proc surveyselect data=RANDSORT
--      method=srs
--      /*rate=0.02*/
--      n=640266
--      seed=123456789
--      out=ecamp.FaceBook_TGCP20160518RNDFDel;
--strata comboid / ALLOC=PROP;
--run;

--update rfm..FaceBook_TGCP20160518RND
--set CustGroup = 'Test'

--select a.*
--from rfm..FaceBook_TGCP20160518RND a
--	join rfm..FaceBook_TGCP20160518RNDFDel b on a.customerid=b.customerid
--										and a.CustomerSegmentPriority = b.CustomerSegmentPriority 
--										and a.ComboID = b.comboid
										


--update a
--set CustGroup = 'Holdout'
--from rfm..FaceBook_TGCP20160518RND a
--	join rfm..FaceBook_TGCP20160518RNDFDel b on a.customerid=b.customerid
--										and a.CustomerSegmentPriority = b.CustomerSegmentPriority 
--										and a.ComboID = b.comboid
										
--select custgroup, COUNT(*)
--from rfm..FaceBook_TGCP20160518RND 
--group by CustGroup										

--update a
--set a.custgroup = b.custgroup
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails a join
--	rfm..FaceBook_TGCP20160518RND b on a.customerid=b.customerid
--										and a.CustomerSegmentPriority = b.CustomerSegmentPriority 
--										and a.CustSegComboForRNDMZ = b.comboid
										
		
--		select CustGroup, COUNT(distinct CustomerID)
--		from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
--		group by CustGroup	
		
--		select customerid, COUNT(distinct CustGroup) Counts
--		into #tempdupe
--		from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
--		group by CustomerID
--		having COUNT(distinct CustGroup) > 1
		
--		select a.*
--		from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails a join
--			#tempdupe b on a.CustomerID = b.CustomerID
--		order by a.CustomerID
		
--		update a
--		set a.CustGroup = 'NotInTest'
--		from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails a join
--			#tempdupe b on a.CustomerID = b.CustomerID
	
	
	-- see if there are emails with different customerIDs
	-- drop table #DupeEmail
		--select email, COUNT(distinct CustGroup) Counts
		----into #DupeEmail
		--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
		--group by email
		--having COUNT(distinct CustGroup) > 1
		
		-- (0 row(s) affected)
		
		
		--select *
		--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
		--where CustomerID is null
	
	
---- Load Prospects	
	
-- drop table Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts	
if object_id ('staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts') is not null
drop table Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts

		
select distinct  a.Subscribed, 
		'' CountryCode,									
		case when (a.HardBounce + a.SoftBounce + a.Blacklist) > 0 then 1								
		else 0 end as BounceFlag,							
		'Prospects' CustomerSegmentFnl,							
		a.CustomerID,
		a.Email,
		CONVERT(int,null) as CustomerSegmentPriority,
		convert(varchar(20),null) as CustType,
		convert(varchar(20),'Test') as CustGroup,
		convert(varchar(50),'Rest') as CustomerSegmentFnlFB,
		convert(varchar(50),null) as CustSegComboForRNDMZ
into Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts
from DataWarehouse.Marketing.epc_preference a left join
	(select *
	from rfm.[dbo].[FaceBook_TGCPlusTest_AllCustWithEmails_20160126Prspcts]	
	where CustGroup = 'Holdout')b on a.Email = b.Email											
where a.CustomerID is null
and a.email not like '%.co.%'
and b.Email is null


delete a
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts	a 
join Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	 b 
on a.Email = b.Email


update Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts
set CustSegComboForRNDMZ = convert(varchar,subscribed) + '_' + convert(varchar,BounceFlag) + '_' + isnull(CustomerSegmentFnlFB,'')


--select distinct CustomerSegmentFnl, CustomerSegmentFnlFB, CustSegComboForRNDMZ
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts
--order by 2

--select top 100 * 
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts

update Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts
set CustType = case when Subscribed = 1  and BounceFlag = 0 then 'Emailable'
					else 'Non_Emailable' end
					

		
--select Subscribed, BounceFlag, CustType, CustGroup, COUNT(*)
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts
--group by Subscribed, BounceFlag, CustType, CustGroup
--order by Subscribed, BounceFlag, CustType, CustGroup
	
--select distinct CustomerSegmentFnl
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts	
								
--- update priority.. so, we do not include same customer with different customerIDs and same email
-- to different groups..
update 	Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts
set CustomerSegmentPriority = null

update 	Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts
set CustomerSegmentPriority = 8


	
--select CustomerSegmentFnl, CustomerSegmentFnlFB, CustSegComboForRNDMZ, CustomerSegmentPriority, COUNT(*)
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts
--group by CustomerSegmentFnl, CustomerSegmentFnlFB, CustSegComboForRNDMZ, CustomerSegmentPriority
--order by CustomerSegmentFnl, CustomerSegmentFnlFB, CustSegComboForRNDMZ, CustomerSegmentPriority
	
--select CustSegComboForRNDMZ, CustomerSegmentPriority, COUNT(*)
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts
--group by CustSegComboForRNDMZ, CustomerSegmentPriority
--order by 2,1

-- create table for randomization

--select len('FaceBook_TGCP20160518RND2')


-- drop table rfm..FaceBook_TGCP20160518RND2

--select distinct a.email, a.CustomerSegmentPriority, a.CustSegComboForRNDMZ as ComboID, a.CustGroup
--into rfm..FaceBook_TGCP20160518RND2
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts a

---- (130783 row(s) affected)

--select 130783.0 * .3  -- 30% holdout
---- 39234.90

-- drop table rfm..FaceBook_TGCP20160518RND2FDel

-- SAS code -- libname ecamp ODBC DSN = ColoSql01  schema = dbo qualifier = LstMgr insertbuff = 32767 bcp=yes;

--options compress=yes obs=max;
--libname ecamp ODBC DSN = TTCDataMart01  schema = dbo qualifier = rfm insertbuff = 32767 bcp=yes;

--proc sort data=ecamp.FaceBook_TGCP20160518RND2 out=RANDSORT;
--by comboid;
--run;

--proc surveyselect data=RANDSORT
--      method=srs
--      /*rate=0.02*/
--      n=39235
--      seed=6789
--      out=ecamp.FaceBook_TGCP20160518RND2FDel;
--strata comboid / ALLOC=PROP;
--run;

--update rfm..FaceBook_TGCP20160518RND2
--set CustGroup = 'Test'

--select a.*
--from rfm..FaceBook_TGCP20160518RND2 a
--	join rfm..FaceBook_TGCP20160518RND2FDel b on a.Email = b.email
										


--update a
--set CustGroup = 'Holdout'
--from rfm..FaceBook_TGCP20160518RND2 a
--	join rfm..FaceBook_TGCP20160518RND2FDel b on a.Email = b.email
										
--select custgroup, COUNT(*)
--from rfm..FaceBook_TGCP20160518RND2 
--group by CustGroup										

--update a
--set a.custgroup = b.custgroup
--from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts a join
--	rfm..FaceBook_TGCP20160518RND2 b on a.Email = b.email
	
insert into Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
select *
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmailsPrspcts 
	
select CustType, CustomerSegmentFnlFB, CustGroup, CustomerSegmentFnl, COUNT(distinct customerID) UnqCustCount, COUNT(email) Emails
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
group by CustType, CustomerSegmentFnlFB, CustGroup, CustomerSegmentFnl


/*
From: Joseph Peckl 
Sent: Wednesday, May 18, 2016 2:34 PM
To: Preethi Ramanujam
Cc: Allison Lesser; Dave Sanders
Subject: Re: Monthly List updates for Facebook

Yes

Sent from my iPhone

On May 18, 2016, at 2:29 PM, Preethi Ramanujam <ramanujamp@TEACHCO.com> wrote:
Joe,
 
Do I still need to holdout the same cohort like we did last month?
 
Thanks,
Preethi
*/
	-- create files
-- To change: 	20160518

/* Truncate FbMonthlyReport  */

truncate table rfm..FbMonthlyReport

Declare @SQL Nvarchar(2000),@Date varchar(8),@Dest Nvarchar(200),@File Nvarchar(200),@table Nvarchar(200),@FileNamepart Nvarchar(200)
set @Date = convert(varchar, getdate(),112)
set @FileNamepart = case when  datepart(m,getdate()) < 10 then '_0' + Cast( datepart(m,getdate()) as varchar (2)) else '_' + Cast( datepart(m,getdate()) as varchar (2)) end + '_' + Cast( datepart(yyyy,getdate()) as varchar (4))
set @Dest = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\SnagFilms\FaceBookCampaigns\FB_MonthlyFiles'+ '_' + @Date


select @FileNamepart FileNamepart,@Dest Dest

EXEC master.dbo.xp_create_subdir @Dest


-- 1. Emailable Active Multi
----------------------------

set @table = 'FB_TGCPTrgt_EmlblActMulti' 
set @File = 'Active_Multis_Email' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Active_Multi'


if object_id ('rfm..FB_TGCPTrgt_EmlblActMulti') is not null
drop table rfm..FB_TGCPTrgt_EmlblActMulti

select distinct Email
into rfm..FB_TGCPTrgt_EmlblActMulti
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Active_Multi'


-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_EmlblActMulti, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\SnagFilms\FaceBookCampaigns'

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File



-- 2. Emailable Active Single
------------------------------

set @table = 'FB_TGCPTrgt_EmlblActSngl' 
set @File = 'Active_Single_Email' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Active_Single'

if object_id ('rfm..FB_TGCPTrgt_EmlblActSngl') is not null
drop table rfm..FB_TGCPTrgt_EmlblActSngl

select distinct Email
into rfm..FB_TGCPTrgt_EmlblActSngl
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Active_Single'
-- (27837 row(s) affected)


-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015

--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_EmlblActSngl, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File

-- 3. Emailable Active Single - New to file
--------------------------------------------------

set @table = 'FB_TGCPTrgt_EmlblNTFSngl' 
set @File = 'NewToFile_Single_Email' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'NewToFile_Single'


if object_id ('rfm..FB_TGCPTrgt_EmlblNTFSngl') is not null
drop table rfm..FB_TGCPTrgt_EmlblNTFSngl

select distinct Email
into rfm..FB_TGCPTrgt_EmlblNTFSngl
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'NewToFile_Single'
 


-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_EmlblNTFSngl, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File


-- 4. Emailable Inactive Multi
----------------------------

set @table = 'FB_TGCPTrgt_EmlblInactMulti' 
set @File = 'Inactive_Multi_Email' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Inactive_Multi'
 

if object_id ('rfm..FB_TGCPTrgt_EmlblInactMulti') is not null
drop table rfm..FB_TGCPTrgt_EmlblInactMulti

select distinct Email
into rfm..FB_TGCPTrgt_EmlblInactMulti
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Inactive_Multi'

-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_EmlblInactMulti, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File	

-- 5. Emailable Inactive Single
------------------------------

set @table = 'FB_TGCPTrgt_EmlblInactSngl' 
set @File = 'Inactive_Single_Email' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Inactive_Single'

if object_id ('rfm..FB_TGCPTrgt_EmlblInactSngl') is not null
drop table rfm..FB_TGCPTrgt_EmlblInactSngl

select distinct Email
into rfm..FB_TGCPTrgt_EmlblInactSngl
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Inactive_Single'

-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_EmlblInactSngl, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'

/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File	


-- 6. Emailable DeepInactive Multi
----------------------------

set @table = 'FB_TGCPTrgt_EmlblDpInMulti' 
set @File = 'DeepInactive_Multi_Email' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'DeepInactive_Multi'

if object_id ('rfm..FB_TGCPTrgt_EmlblDpInMulti') is not null
drop table rfm..FB_TGCPTrgt_EmlblDpInMulti

select distinct Email
into rfm..FB_TGCPTrgt_EmlblDpInMulti
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'DeepInactive_Multi'


-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_EmlblDpInMulti, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File	
	

-- 7. Emailable DeepInactive Single
------------------------------
set @table = 'FB_TGCPTrgt_EmlblDpInSngl' 
set @File = 'DeepInactive_Single_Email' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'DeepInactive_Single'

if object_id ('rfm..FB_TGCPTrgt_EmlblDpInSngl') is not null
drop table rfm..FB_TGCPTrgt_EmlblDpInSngl

select distinct Email
into rfm..FB_TGCPTrgt_EmlblDpInSngl
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'DeepInactive_Single'

-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_EmlblDpInSngl, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File	


-- 8. Emailable REst (Inquirers, No RFM, Prospects)
----------------------------

set @table = 'FB_TGCPTrgt_EmlblRest' 
set @File = 'Rest_Email' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Rest'


if object_id ('rfm..FB_TGCPTrgt_EmlblRest') is not null
drop table rfm..FB_TGCPTrgt_EmlblRest

select distinct Email
into rfm..FB_TGCPTrgt_EmlblRest
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Rest'

-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_EmlblRest, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File		


---------------------------------------------------------------------------------------
-- Non emailable group
---------------------------------------------------------------------------------------

-- 1. Non_Emailable Active Multi
----------------------------

set @table = 'FB_TGCPTrgt_NonEmActMulti' 
set @File = 'Active_Multi_NonEmail' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Active_Multi'


if object_id ('rfm..FB_TGCPTrgt_NonEmActMulti') is not null
drop table rfm..FB_TGCPTrgt_NonEmActMulti

select distinct Email
into rfm..FB_TGCPTrgt_NonEmActMulti
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Active_Multi'


-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_NonEmActMulti, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File	
	

-- 2. Non_Emailable Active Single
------------------------------
set @table = 'FB_TGCPTrgt_NonEmActSngl' 
set @File = 'Active_Single_NonEmail' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Active_Single'


if object_id ('rfm..FB_TGCPTrgt_NonEmActSngl') is not null
drop table rfm..FB_TGCPTrgt_NonEmActSngl

select distinct Email
into rfm..FB_TGCPTrgt_NonEmActSngl
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Active_Single'



-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_NonEmActSngl, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File	


-- 3. Non_Emailable Active Single - New to file
--------------------------------------------------
set @table = 'FB_TGCPTrgt_NonEmNTFSngl' 
set @File = 'NewToFile_Single_NonEmail' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'NewToFile_Single'

if object_id ('rfm..FB_TGCPTrgt_NonEmNTFSngl') is not null
drop table rfm..FB_TGCPTrgt_NonEmNTFSngl

select distinct Email
into rfm..FB_TGCPTrgt_NonEmNTFSngl
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'NewToFile_Single'


-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_NonEmNTFSngl, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File	


-- 4. Non_Emailable Inactive Multi
----------------------------
set @table = 'FB_TGCPTrgt_NonEmInactMulti' 
set @File = 'Inactive_Multi_NonEmail' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts 
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Inactive_Multi'

if object_id ('rfm..FB_TGCPTrgt_NonEmInactMulti') is not null
drop table rfm..FB_TGCPTrgt_NonEmInactMulti

select distinct Email
into rfm..FB_TGCPTrgt_NonEmInactMulti
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Inactive_Multi'

-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_NonEmInactMulti, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File	
	

-- 5. Non_Emailable Inactive Single
------------------------------
set @table = 'FB_TGCPTrgt_NonEmInactSngl' 
set @File = 'Inactive_Single_NonEmail' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Inactive_Single'


if object_id ('rfm..FB_TGCPTrgt_NonEmInactSngl') is not null
drop table rfm..FB_TGCPTrgt_NonEmInactSngl

select distinct Email
into rfm..FB_TGCPTrgt_NonEmInactSngl
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Inactive_Single'

-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_NonEmInactSngl, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File	

-- 6. Non_Emailable DeepInactive Multi
----------------------------
set @table = 'FB_TGCPTrgt_NonEmDpInMulti' 
set @File = 'DeepInactive_Multi_NonEmail' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'DeepInactive_Multi'


if object_id ('rfm..FB_TGCPTrgt_NonEmDpInMulti') is not null
drop table rfm..FB_TGCPTrgt_NonEmDpInMulti

select distinct Email
into rfm..FB_TGCPTrgt_NonEmDpInMulti
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'DeepInactive_Multi'

-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_NonEmDpInMulti, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File	
	

-- 7. Non_Emailable DeepInactive Single
------------------------------
set @table = 'FB_TGCPTrgt_NonEmDpInSngl' 
set @File = 'DeepInactive_Single_NonEmail' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'DeepInactive_Single'

if object_id ('rfm..FB_TGCPTrgt_NonEmDpInSngl') is not null
drop table rfm..FB_TGCPTrgt_NonEmDpInSngl

select distinct Email
into rfm..FB_TGCPTrgt_NonEmDpInSngl
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'DeepInactive_Single'

-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_NonEmDpInSngl, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File


-- 8. Non_Emailable REst (Inquirers, No RFM, Prospects)
----------------------------
set @table = 'FB_TGCPTrgt_NonEmRest' 
set @File = 'Rest_NonEmail' + @FileNamepart + '.txt'

insert into rfm..FbMonthlyReport 
(Tablename,Counts)
select @File, Count(*) as Cnts
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Rest'

if object_id ('rfm..FB_TGCPTrgt_NonEmRest') is not null
drop table rfm..FB_TGCPTrgt_NonEmRest

select distinct Email
into rfm..FB_TGCPTrgt_NonEmRest
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails	
where CustType = 'Non_Emailable'
and CustGroup = 'test'
and CustomerSegmentFnlFB = 'Rest'

-- Run this to transfer the table to the folder:
-- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_NonEmRest, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @table, @Dest,@File
	
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-------- TGCPLUS  -- Wait till tomorrow to include WD updates...
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

------------------------- subscribers for Model

--select TransactionType, count(*)
--from DataWarehouse.Marketing.TGCPlus_CustomerSignature
--group by TransactionType

--select COUNT(*) 
--from DataWarehouse.Marketing.TGCPlus_CustomerSignature
--where TransactionType <> 'Cancelled'
---- (7872 row(s) affected)

--select distinct EmailAddress
--into rfm..FB_TGCP_Subscribers
--from DataWarehouse.Marketing.TGCPlus_CustomerSignature
--where TransactionType <> 'Cancelled'
---- (7872 row(s) affected)


---- Run this to transfer the table to the folder:
---- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCP_Subscribers, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'

	
----------------------- Cancelled for Facebook Retargeting

--select TransactionType, count(*)
--from DataWarehouse.Marketing.TGCPlus_CustomerSignature
--group by TransactionType

--select COUNT(*) 
--from DataWarehouse.Marketing.TGCPlus_CustomerSignature
--where TransactionType = 'Cancelled'
---- (4700 row(s) affected)

--select distinct EmailAddress
--into rfm..FB_TGCPTrgt_Cancelled
--from DataWarehouse.Marketing.TGCPlus_CustomerSignature
--where TransactionType = 'Cancelled'
---- (4700 row(s) affected)


---- Run this to transfer the table to the folder:
---- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_Cancelled, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'

----------------------- Beta Users ONLY for Facebook Retargeting

--select TransactionType, count(*)
--from DataWarehouse.Marketing.TGCPlus_CustomerSignature
--group by TransactionType

--select distinct a.email as EmailAddress
--from DataWarehouse.Archive.TGCPlus_User a join
--	DataWarehouse.Mapping.Vw_TGCPlus_ValidSubscriptionPlan b on a.subscription_plan_id = b.id left join
--	DataWarehouse.Marketing.TGCPlus_CustomerSignature c on a.email = c.EmailAddress
--where c.EmailAddress is null
--and joined <= '9/29/2015'
--and email not like '%+%'
--and a.subscription_plan_id = 27

---- (4700 row(s) affected)


--select distinct a.email as EmailAddress
--into rfm..FB_TGCPTrgt_BETA
--from DataWarehouse.Archive.TGCPlus_User a join
--	DataWarehouse.Mapping.Vw_TGCPlus_ValidSubscriptionPlan b on a.subscription_plan_id = b.id left join
--	DataWarehouse.Marketing.TGCPlus_CustomerSignature c on a.email = c.EmailAddress
--where c.EmailAddress is null
--and joined <= '9/29/2015'
--and email not like '%+%'
--and a.subscription_plan_id = 27
---- (4700 row(s) affected)


---- Run this to transfer the table to the folder:
---- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_BETA, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'


----------------------- Registarations ONLY for Facebook Retargeting

--select TransactionType, count(*)
--from DataWarehouse.Marketing.TGCPlus_CustomerSignature
--group by TransactionType

--select distinct a.email as EmailAddress
--from DataWarehouse.Archive.TGCPlus_User a  left join
--	DataWarehouse.Marketing.TGCPlus_CustomerSignature c on a.email = c.EmailAddress
--where c.EmailAddress is null
--and joined >= '9/28/2015'
--and email not like '%+%'
--and entitled_dt is null
 


--select distinct a.email as EmailAddress
--into rfm..FB_TGCPTrgt_Registrations
--from DataWarehouse.Archive.TGCPlus_User a  left join
--	DataWarehouse.Marketing.TGCPlus_CustomerSignature c on a.email = c.EmailAddress
--where c.EmailAddress is null
--and joined >= '9/28/2015'
--and email not like '%+%'
--and entitled_dt is null
---- (4700 row(s) affected)


---- Run this to transfer the table to the folder:
---- \\File1\Marketing\Plan2K15\Outside Mailings\Prospect Catalogs\Australia\OSW4\Greater Data\Pre Merge\AU_HousefileForMerge_Wave4_2015
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, FB_TGCPTrgt_Registrations, '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\'

		

-- Final Report:
--use rfm


--SELECT 
--    [FileName] = so.name + 'FNL.txt',
--    [CustomerType] = case when so.name like 'FB_TGCPTrgt_Emlbl%' then 'Emailable'
--							when so.name like 'FB_TGCPTrgt_NonEm%' then 'Non_Emaialble'
--							else 'Unknown'
--						end, 
--    [CustomerSegment] = case when so.name like '%[ml]ActMulti%' then 'Active Multi'
--							when so.name like '%[ml]ActSngl%' then 'Active Singles'
--							when so.name like '%NTF%' then 'New to File Singles'
--							when so.name like '%InactMulti%' then 'Inactive Multi'
--							when so.name like '%InactSngl%' then 'Inactive Singles'
--							when so.name like '%DpInMulti%' then 'DeepInactive Multi'
--							when so.name like '%DpInSngl%' then 'DeepInactive Singles'
--							when so.name like '%Rest%' then 'Rest: Inquirers, NoRFM, Prospects'
--							else 'Unknown'
--						end, 
--    [RowCount] = MAX(si.rows),    
--    cast(so.crdate as date) DateCreated
--FROM sysobjects so, 
--    sysindexes si 
--WHERE so.xtype = 'U' 
--    AND si.id = OBJECT_ID(so.name) 
--    and so.name like 'FB_TGCP%_%20160518'
--GROUP BY so.name, so.crdate
--ORDER BY 2,3


set @SQL =	'
			IF OBJECT_ID (''RFM..FaceBook_TGCPlusTest_AllCustWithEmails_' + @Date +''')IS NOT NULL
			DROP TABLE rfm..FaceBook_TGCPlusTest_AllCustWithEmails_' + @Date +'

			select * 
			into rfm..FaceBook_TGCPlusTest_AllCustWithEmails_' + @Date +'
			from DataWarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails '

Exec (@sql)

-- Campaign Count Report
select CustType, CustomerSegmentFnlFB, CustGroup, CustomerSegmentFnl, COUNT(distinct customerID) UnqCustCount, COUNT(email) Emails
from Datawarehouse.staging.FaceBook_TGCPlusTest_AllCustWithEmails
group by CustType, CustomerSegmentFnlFB, CustGroup, CustomerSegmentFnl



DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(max)
DECLARE @p_recipients as nvarchar(max), @p_profile_name as nvarchar(max)
SET @p_profile_name = N'DL datamart alerts'
SET @p_recipients = N'~dldatamartalerts@TEACHCO.com'
SET @p_subject = N'FaceBook Monthly Report'
SET @p_body = '<b>Facebook Monthly Report has been created</b>.  
let others know that the report is ready here ' + @Dest + '

For Report Run the below:
Select * from rfm..FbMonthlyReport

'
EXEC msdb.dbo.sp_send_dbmail
  @profile_name = @p_profile_name,
  @recipients = @p_recipients,
  @body = @p_body,
  @body_format = 'HTML',
  @subject = @p_subject


End


GO
