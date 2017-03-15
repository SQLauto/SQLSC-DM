SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Proc [dbo].[SP_CreateBiWeekly_TopRatedCnvrtlgMailFile]
As

begin

-- Convertalog data for LCM2_no2
-- Pull Date: 12/16	- acquistion weeks 1/26 and 1/19 -
-- To change...
-- drop date: 20150223
--Date based of running schedule next monday

declare @date varchar(8),@year varchar(8), @ExecSQL nvarchar(max)
select @date=cast(cast(convert(char(8), dateadd(week, datediff(week, 0, getdate()), 7), 112) as int)  as varchar(8))
--select @date

set @year = datepart(yyyy,@date)

/*
--Check 1
select distinct AcquisitionWeek from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid
where DATEDIFF(week, acquisitionweek, getdate()) in (5,6)
*/

-- drop table #Adcodes
select  a.*, DATEDIFF(week, a.AcquisitionWeek, getdate()) WeekSince, b.CatalogCode, b.CatalogName,
	b.MD_Country, b.MD_Year, b.ChannelID as MD_ChannelID, b.MD_Channel,
	b.MD_PromotionTypeID, b.MD_PromotionType, b.MD_CampaignID, b.MD_CampaignName,
	b.StartDate, dateadd(d,3,Staging.GetMonday(b.StopDate)) as StopDate /*Expiration date changed due to date mismatch expiring on thursday of the week*/
into #Adcodes
from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid a join
	DataWarehouse.Mapping.vwAdcodesAll b on a.Adcode = b.AdCode
where EmailType = 'TopRated'
and DATEDIFF(week, acquisitionweek, getdate()) in (5,6)

/*
--check 2
select * from #Adcodes
--check 3
select * from rfm..WPTest_Random2013
where DATEDIFF(week, acquisitionweek, getdate()) in (5,6) 
and CustGroup = 'Test'
*/


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Temp_CnvtTopRated]') AND type in (N'U'))
DROP TABLE Temp_CnvtTopRated


SELECT distinct CCS.CustomerID, CCS.BuyerType, CCS.NewSeg, CCS.Name, 
	CCS.a12mf, CCS.ComboID, CCS.Concatenated Concantonated,
	CCS.CustomerSegment, CCS.Frequency, CCS.FMPullDate, cast(c.startdate AS date) StartDate, 
	cast(c.StopDate AS date) StopDate,
	CCS.Prefix, CCS.FirstName, CCS.MiddleName MiddleInitial, CCS.LastName, CCS.Suffix, 
	CCS.CompanyName as Company, 
	ccs.Address1 + ' '  + ccs.Address2 as Address1,
    ccs.Address3 as Address2, CCS.City, CCS.State, CCS.PostalCode, 
	c.Adcode, CCS.AH, CCS.EC, CCS.FA, CCS.HS, CCS.LIT, CCS.MH, CCS.PH, CCS.RL, CCS.SC, 
	CCS.FlagMail, CCS.PreferredCategory, CCS.PreferredCategory2, CCS.PublicLibrary,
	CCS.FlagValidRegionUS FlagValidRegion, 0 as FlagWelcomeBack,
	b.CustGroup, b.HVLVGroup, b.AcquisitionWeek,
	convert(varchar(30),c.MD_CampaignName) + case when c.HVLVGroup = 'HV' then '_PM4'
						 when c.HVLVGroup = 'MV' then '_PM5'
						 when c.HVLVGroup = 'LV' then '_PM8'
						  else ''
					end as VersionName
INTO Temp_CnvtTopRated
FROM  Datawarehouse.Marketing.campaigncustomersignature CCS 
	join (select * from rfm..WPTest_Random2013
		where DATEDIFF(week, acquisitionweek, getdate()) in (5,6) 
		and CustGroup = 'Control')b on CCS.customerid = b.CustomerID
	join #Adcodes c on b.AcquisitionWeek = c.AcquisitionWeek
					and b.CustGroup = c.CustGroup
					and b.HVLVGroup = c.HVLVGroup		
WHERE CCS.FlagMail = 1 
AND CCS.PublicLibrary = 0 
AND CCS.FlagValidRegionUS = 1
AND ISNULL(CCS.Frequency,'F1') = 'F1'


Create index ix_Temp_CnvtTopRated on Temp_CnvtTopRated (customerid)


/*
--check later
-- Make sure prior mailing was added in the history table.
select a.AdCode, b.Name, a.StartDate, COUNT(customerID) CustCount
from DataWarehouse.Archive.MailingHistory_Convertalog a join
	superstardw..MktAdCodes b on a.AdCode = b.AdCode
where StartDate >= (select MAX(startdate) Startdate from DataWarehouse.Archive.MailingHistory_Convertalog)
group by a.AdCode, b.Name, a.StartDate
order by 1
*/


/*
-- do not DELETE PRIOR CONVERTALOG RECIPIENTS
select count(a.customerid)
from Temp_CnvtTopRated  a join
	Datawarehouse.Archive.MailingHistory_Convertalog b on a.customerid = b.Customerid
	
--delete a
--from Temp_CnvtTopRated  a join
--	Datawarehouse.Archive.MailingHistory_Convertalog b on a.customerid = b.Customerid
--	-- 174863
*/

/*
--check 
select convert(datetime,Convert(varchar,b.CustomerSince,101)) CustomerSince, 
	Count(distinct a.customerid)
from Temp_CnvtTopRated a join
	Datawarehouse.Marketing.campaigncustomersignature b on a.customerid = b.customerid
--where a.adcode in (43649, 43758)
group by convert(datetime,Convert(varchar,b.CustomerSince,101))
--having COUNT(distinct a.customerid) > 10
order by 1 desc
*/

-- Send the counts to Chris R to make sure quantities are good and we
-- have enough inventory (these are pre printed at the beginning of the year)
/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT a.adcode, c.adcodeName, c.CatalogCode, c.CatalogName,
	 a.CustGroup, a.HVLVGroup, count(a.customerid) CustCount--, b.AcquisitionWeek
from  Temp_CnvtTopRated a join
	datawarehouse.mapping.vwadcodesall c on a.Adcode = c.adcode join
	(select *
	from rfm..WPTest_Random2013)b on A.customerID = b.CustomerID
group by  a.adcode, c.adcodeName, c.CatalogCode, c.CatalogName, a.CustGroup, a.HVLVGroup
order by 1,2

/*
adcode      adcodeName                                         CatalogCode CatalogName                                        CustGroup HVLVGroup CustCount
----------- -------------------------------------------------- ----------- -------------------------------------------------- --------- --------- -----------
111031      NCC: TopRated Convert Drop 02/23/15 PM             51644       NCC: TopRated Convert WK 01/05 & 01/12 Drop 02/23/ TEST      HV        2573
111084      NCC: TopRated Convert Drop 02/23/15 PM             51697       NCC: TopRated Convert WK 01/05 & 01/12 Drop 02/23/ TEST      MV        1299
111137      NCC: TopRated Convert Drop 02/23/15 PM             51750       NCC: TopRated Convert WK 01/05 & 01/12 Drop 02/23/ TEST      LV        3077

(3 row(s) affected)

*/


SELECT a.adcode, c.adcodeName, c.CatalogCode, c.CatalogName, a.AcquisitionWeek,
	 a.CustGroup, a.HVLVGroup, count(a.customerid) CustCount--, b.AcquisitionWeek
from  Temp_CnvtTopRated a join
	datawarehouse.mapping.vwadcodesall c on a.Adcode = c.adcode join
	(select *
	from rfm..WPTest_Random2013)b on A.customerID = b.CustomerID
group by  a.adcode, c.adcodeName, c.CatalogCode, c.CatalogName, a.AcquisitionWeek, a.CustGroup, a.HVLVGroup
order by 1,2

/*
adcode      adcodeName                                         CatalogCode CatalogName                                        AcquisitionWeek         CustGroup HVLVGroup CustCount
----------- -------------------------------------------------- ----------- -------------------------------------------------- ----------------------- --------- --------- -----------
111031      NCC: TopRated Convert Drop 02/23/15 PM             51644       NCC: TopRated Convert WK 01/05 & 01/12 Drop 02/23/ 2015-01-05 00:00:00.000 Test      HV        1242
111031      NCC: TopRated Convert Drop 02/23/15 PM             51644       NCC: TopRated Convert WK 01/05 & 01/12 Drop 02/23/ 2015-01-12 00:00:00.000 TEST      HV        1331
111084      NCC: TopRated Convert Drop 02/23/15 PM             51697       NCC: TopRated Convert WK 01/05 & 01/12 Drop 02/23/ 2015-01-05 00:00:00.000 Test      MV        615
111084      NCC: TopRated Convert Drop 02/23/15 PM             51697       NCC: TopRated Convert WK 01/05 & 01/12 Drop 02/23/ 2015-01-12 00:00:00.000 TEST      MV        684
111137      NCC: TopRated Convert Drop 02/23/15 PM             51750       NCC: TopRated Convert WK 01/05 & 01/12 Drop 02/23/ 2015-01-12 00:00:00.000 TEST      LV        1652
111137      NCC: TopRated Convert Drop 02/23/15 PM             51750       NCC: TopRated Convert WK 01/05 & 01/12 Drop 02/23/ 2015-01-05 00:00:00.000 Test      LV        1425

(6 row(s) affected)


*/


*/



-- Create mail file for Quad

/*
select *
into Temp_CnvtTopRated_QuadBKPBAD
from Temp_CnvtTopRated_Quad
*/
/*
select distinct stopdate, upper(datename(WEEKDAY,StopDate)) + ' ' + upper(left(DATENAME(MONTH,stopdate),3)) + ' ' + convert(varchar,DAY(stopdate)) + ', ' + CONVERT(varchar, YEAR(StopDate))
from Temp_CnvtTopRated
*/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Temp_CnvtTopRated_Quad]') AND type in (N'U'))
drop TABLE Temp_CnvtTopRated_Quad


SELECT Convert(varchar(150),
	Ltrim(rtrim(Prefix + ' ' + FirstName + ' ' + LastName + ' ' + Suffix))) FullName1,
	Company as Company1, 
	Address1 as Altrntddr1,
	Address2 AltrntAddr2, 
	convert(varchar(250),'') DLVRYDDRSS, 
	City, 
	State, 
	PostalCode as Zip4, 
	AdCode as ConvertalogAdcode, 
	CustomerID,  
	upper(datename(WEEKDAY,StopDate)) + ' ' + upper(left(DATENAME(MONTH,stopdate),3)) + ' ' + convert(varchar,DAY(stopdate)) + ', ' + CONVERT(varchar, YEAR(StopDate)) as Expire,
	VersionName
INTO Temp_CnvtTopRated_Quad
from  Temp_CnvtTopRated 
where AdCode > 0

--(6949 row(s) affected)


/*
select a.VersionName, a.ConvertalogAdcode, b.adcodename, b.catalogcode, 
	count(a.customerid) CustCount 
from Temp_CnvtTopRated_Quad a left outer join 
	datawarehouse.mapping.vwadcodesall b on a.ConvertalogAdcode = b.adcode
	where customerid <> 99999999
	group by a.VersionName, a.ConvertalogAdcode, b.adcodename, b.catalogcode
	order by 2,1

/*
VersionName                        ConvertalogAdcode adcodename                                         catalogcode CustCount
---------------------------------- ----------------- -------------------------------------------------- ----------- -----------
Top Rated Convertalog_PM4          111031            NCC: TopRated Convert Drop 02/23/15 PM             51644       2573
Top Rated Convertalog_PM5          111084            NCC: TopRated Convert Drop 02/23/15 PM             51697       1299
Top Rated Convertalog_PM8          111137            NCC: TopRated Convert Drop 02/23/15 PM             51750       3077

(3 row(s) affected)
*/



select count(*) from Temp_CnvtTopRated_Quad

*/

------------------------------------------ Add seed list-----------------------------------------------------------------------------------------
--select * from Datawarehouse.Mapping.SeedNames_Convertalog


INSERT INTO Temp_CnvtTopRated_Quad
select a.FullName1, '', a.Altrntddr1, '', '', a.City, a.State, a.Zip4,
	b.ConvertalogAdcode, 99999999 as CustomerID,
	b.Expire, b.VersionName
from Datawarehouse.Mapping.SeedNames_Convertalog a,
	(select distinct convertalogadcode, expire, VersionName
	from Temp_CnvtTopRated_Quad)b
	
--(140 row(s) affected)
/*	
	exec rfm..GetAdcodeInfo Temp_CnvtTopRated, datawarehouse
	select * from rfm..MailFile_SeedNames_Experian
*/


	
------------------------------------------------ Add Hauser seed list only if needed-------------------------------------------------------------
/* Ignore for now*/

/*
INSERT INTO Temp_CnvtTopRated_Quad
select a.FirstName + ' ' + a.LastName as FullName1, 
	'', a.Address1 as Altrntddr1, '', '', a.City, a.State, a.ZipCode as Zip4,
	b.ConvertalogAdcode, 99999999 as CustomerID,
	b.Expire, b.SubjectCategory
from (select * from rfm..MailFile_SeedNames_Experian 
	where adcode = 99999)a,
	(select distinct convertalogadcode, expire, subjectcategory
	from Temp_CnvtTopRated_Quad)b	
	where convertalogAdcode = 64075)b	
*/


--************************************-----------NoT SURE if we need to delete seeds-------------------------------------------------------------********NOT Sure

/*	
select ConvertalogAdcode, COUNT(customerID) 
from Temp_CnvtTopRated_Quad
where CustomerID = 99999999
group by ConvertalogAdcode

delete from Temp_CnvtTopRated_Quad
where CustomerID = 99999999
*/

-----------------------------------------------------------------Clean address------------------------------------------------------------------

update  Temp_CnvtTopRated_Quad
set Altrntddr1 = replace(replace(ISNULL(Altrntddr1,''),char(13),''),char(10),''),
	AltrntAddr2 = replace(replace(ISNULL(AltrntAddr2,''),char(13),''),char(10),''),
	company1 = replace(replace(ISNULL(company1,''),char(13),''),char(10),'')


update  Temp_CnvtTopRated_Quad
set Altrntddr1 = replace(Altrntddr1,'|',''),
	AltrntAddr2 = replace(AltrntAddr2,'|',''),
	company1 = replace(company1,'|','')


--select * from Temp_CnvtTopRated_Quad

--select * from Temp_CnvtTopRated_Quad
--where fullname1 like '%-%'

update Temp_CnvtTopRated_Quad
set fullname1 =REPLACE(fullname1,'----','')

------------------------------------------------------------------------QC-------------------------------------------------------------------------
-- FINAL QC

Print 'Final QC #1'
SELECT CAST(a.AcquisitionWeek as date) AcquisitionWeek, 
	a.Adcode, 
	cast(b.adcodeName as varchar(80)) adcodeName, 
	b.CustGroup, 
	cast(b.HVLVGroup as varchar(10)) as HVLVGroup,
	cast(c.Startdate as DATE) as MailDate, 
	cast(c.StopDate as DATE) as ExpireDate, 
	count(distinct a.customerid) CustCount
from  Temp_CnvtTopRated a left join
	datawarehouse.mapping.vwadcodesall c on a.Adcode = c.adcode join
	#adcodes b on a.Adcode = b.adcode
				and a.acquisitionWeek = b.acquisitionweek
where customerid < 99999999
group by CAST(a.AcquisitionWeek as date), a.Adcode, b.adcodeName, b.CustGroup, b.HVLVGroup,
	cast(c.Startdate as DATE), 
	cast(c.StopDate as DATE)
order by 1,2

-- Final QC #2
Print 'Final QC #2'
SELECT A.VersionName, a.Adcode as ConvertalogAdcode, cast(b.adcodeName as varchar(80)) as adcodeName, 
	cast(c.Startdate as DATE) as MailDate, 
	cast(c.StopDate as DATE) as ExpireDate, 
	count(distinct a.customerid)
from  Temp_CnvtTopRated a left join
	datawarehouse.mapping.vwadcodesall c on a.Adcode = c.adcode join
	(select distinct adcode, AdcodeName from #adcodes)b on a.Adcode = b.adcode
where customerid < 99999999
group by A.VersionName, a.Adcode, b.adcodeName, 
	cast(c.Startdate as DATE), 
	cast(c.StopDate as DATE)
order by 2

-- Final QC #3
Print 'Final QC #3'
select convert(datetime,Convert(varchar,b.CustomerSince,101)) CustomerSince, 
	Count(distinct a.customerid) CustCount
from Temp_CnvtTopRated a join
	Datawarehouse.Marketing.campaigncustomersignature b on a.customerid = b.customerid
--where a.adcode in (43649, 43758)
group by convert(datetime,Convert(varchar,b.CustomerSince,101))
--having COUNT(distinct a.customerid) > 10
order by 1 desc,2

/*
-- Final QC #4
Print 'Final QC #4'
select convert(datetime,Convert(varchar,b.CustomerSince,101)) CustomerSince, 
	a.FlagWelcomeBack,
	Count(a.customerid) CustCount
from Temp_CnvtTopRated a join
	Datawarehouse.Marketing.campaigncustomersignature b on a.customerid = b.customerid
--where a.adcode in (43649, 43758)
group by convert(datetime,Convert(varchar,b.CustomerSince,101)), a.FlagWelcomeBack
--having COUNT(distinct a.customerid) > 10
order by 1 desc,2
*/

-- For 'QC for Test' tab
Print 'QC for Test tab'
SELECT b.AcquisitionWeek, b.CustGroup, b.HVLVGroup, a.adcode, c.adcodeName, count(a.customerid) CustCount
from  Temp_CnvtTopRated a join
	datawarehouse.mapping.vwadcodesall c on a.Adcode = c.adcode join
	(select *
	from rfm..WPTest_Random2013)b on A.customerID = b.CustomerID
								and a.AcquisitionWeek = b.AcquisitionWeek
group by b.AcquisitionWeek, b.CustGroup, b.HVLVGroup, a.adcode, c.adcodeName
order by 1,2,3,4


--Insert into dated tables
set @ExecSQL = 'select * into rfm.dbo.Mail_US_Convertalog_TopRated_' + @date + '  from Temp_CnvtTopRated'
exec sp_executesql @ExecSQL
--select  @ExecSQL

--Insert into dated tables
set @ExecSQL = 'select * into rfm.dbo.Mail_US_Convertalog_TopRated_' + @date + '_Quad from Temp_CnvtTopRated_Quad'
exec sp_executesql @ExecSQL
--select  @ExecSQL

set @ExecSQL = 'exec staging.ExportTableToPipeText rfm, dbo, Mail_US_Convertalog_TopRated_' + @date + '_Quad, ''\\File1\Groups\Marketing\MailFiles\'+ @year +'\US\Convertalog'', ''Convertalog_TopRated_'+ @date + '_Quad.TXT'''
exec sp_executesql  @ExecSQL 
--select  @ExecSQL 
-- Transfer data to appropriate directory
--use DataWarehouse
--exec staging.ExportTableToPipeText rfm, dbo, Mail_US_Convertalog_TopRated_20150223_Quad, '\\File1\Groups\Marketing\MailFiles\2015\US\Convertalog', 'Convertalog_TopRated_20150223_Quad.TXT'
/*
set @ExecSQL = 'exec staging.ExportTableToPipeText rfm, dbo, Mail_US_Convertalog_TopRated_' + @date + '_Quad, ''\\File1\Groups\Automate\FTP\QuadGraphics\'', ''Convertalog_TopRated_'+ @date + '_Quad.TXT'''
exec sp_executesql  @ExecSQL 
*/
--exec staging.ExportTableToPipeText rfm, dbo, Mail_US_Convertalog_TopRated_20150223_Quad, '\\File1\Groups\Automate\FTP\QuadGraphics\', 'Convertalog_TopRated_20150223_Quad.TXT'

print 'Email Below to group Vikram, Preethi, Julia, Chris R, Brad Brown, Kim P'

set @ExecSQL = 'print ''Zip Name: Convertalog_TopRated_' + @date +'_Quad.zip''
print ''''
print ''File Name: Convertalog_TopRated_' + @date +'_Quad.TXT'''

exec sp_executesql @ExecSQL

set @ExecSQL = 'select count(*) as Total_record_cnt from rfm.dbo.Mail_US_Convertalog_TopRated_' + @date + '_Quad'
exec sp_executesql @ExecSQL
 
 -- Final QC #2
Print 'Final QC #2'
SELECT A.VersionName, a.ConvertalogAdcode, cast(b.adcodeName as varchar(80)) as adcodeName, 
	cast(c.Startdate as DATE) as MailDate, 
	cast(c.StopDate as DATE) as ExpireDate, 
	count(distinct a.customerid)
from  Temp_CnvtTopRated_Quad a left join
	datawarehouse.mapping.vwadcodesall c on a.ConvertalogAdcode = c.adcode join
	(select distinct adcode, AdcodeName from #adcodes)b on a.ConvertalogAdcode = b.adcode
where customerid < 99999999
group by A.VersionName, a.ConvertalogAdcode, b.adcodeName, 
	cast(c.Startdate as DATE), 
	cast(c.StopDate as DATE)
order by 2
 
-- ADD Convertalog data to convertalog history table
/* 
select *
-- delete 
from Datawarehouse.Archive.MailingHistory_Convertalog
where startdate = '12/29/2014'
*/

--select * from  Datawarehouse.Archive.MailingHistory_Convertalog
--where StartDate = '2/9/2015'

------------------------------------------------------------insert to mailing history----------------------------------------------------------------------------
print 'Inserting into History'

insert into Datawarehouse.Archive.MailingHistory_Convertalog
select customerid, adcode, StartDate, NewSeg, Name, A12mf, 
	Concantonated, 0 as FlagHoldout, ComboID, '' as SubjRank, PreferredCategory2
from Temp_CnvtTopRated

------------------------------------------------------------insert to mailing history----------------------------------------------------------------------------
/*
--(20658 row(s) affected)
--delete from Datawarehouse.Archive.MailingHistory_Convertalog
--where StartDate = '12/29/2014'
----- ADD Convertalog data to convertalog history table
--insert into Datawarehouse.Archive.MailingHistory_Convertalog
--select a.CustomerID, b.ConvertalogAdcode, '12/29/2014', NewSeg, Name, A12mf, 
--	Concantonated, 
--	case when b.ConvertalogAdcode = 78759 then 1 else 0 end as FlagHoldout, 
--	ComboID, '', PreferredCategory2
--from rfm..Mail_US_Convertalog_TopRated_20150223 a join
--	rfm..Mail_US_Convertalog_TopRated_20150223_Quad b on a.CustomerID = b.customerid
----(52988 row(s) affected)
--select top 100 * from datawarehouse.archive.MailingHistory_Convertalog
----- ADD Convertalog data to convertalog history table
--insert into Datawarehouse.Archive.MailingHistory_Convertalog
--select customerid, adcode, '12/29/2014', NewSeg, Name, A12mf, 
--	Concantonated, 
--	case when adcode = 78759 then 1 else 0 end as FlagHoldout, 
--	ComboID, '', PreferredCategory2
--from rfm..Mail_US_Convertalog_TopRated_20150223
----(52988 row(s) affected)
*/

drop table #Adcodes

end








GO
