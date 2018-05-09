SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


  
CREATE Proc [dbo].[Sp_EmailPull_LandingPageUpdate_CYC_20180417]  @emailid varchar(200)      
as      
Begin      
-- To create web landing page      
-- 1/13      
-- Step1: Update the course list to this table      
      
declare @startdate date,@stopdate date, @countrycd varchar(10),@count int,@matchcount int,@tablenm varchar(300),@SQL varchar(max)      
      
Select top 1 @startdate = cast(dateadd(d,0,max(startdate)) as DATE),      
     @stopdate = cast(dateadd(d,4,max(EndDate)) as DATE) ,      
     @countrycd = replace(max(Countrycode),'GB','UK')      
    from DataWarehouse.Mapping.Email_adcode_CYC (nolock)      
where EmailID=@emailid      
and Countrycode in ('US','GB','UK','AU')       
      
select @count = isnull(count(CourseID),0)       
from DataWarehouse.Mapping.email_landingpage      
where EmailID=@emailid      
      
--Truncate table      
truncate table datawarehouse.mapping.WebLP_InputCourse      
      
      
insert into datawarehouse.mapping.WebLP_InputCourse      
select CourseID, 0      
from DataWarehouse.Mapping.DMCourse      
where CourseID in       
(select CourseID       
from DataWarehouse.Mapping.email_landingpage      
where EmailID=@emailid      
)      
      
      
select @matchcount = isnull(count(distinct MPM.CourseID),0)      
FROM datawarehouse.mapping.WebLP_InputCourse mpm       
JOIN DataWarehouse.Mapping.dmcourse mc on mpm.courseid = mc.courseid      
      
select @matchcount as CourseCNT,@count InitialCNT      
If @matchcount<>@count      
begin      
RAISERROR (N'There is mismatch in the course counts for landing page.', -- Message text.      
           10, -- Severity,      
           1 -- State,      
); -- Second argument.      
      
Return      
end      
      
/*      
-- Check the course list..      
select MPM.CourseID, MC.CourseName, MC.SubjectCategory2, BundleFlag, mpm.rank      
FROM datawarehouse.mapping.WebLP_InputCourse mpm JOIN      
 DataWarehouse.Mapping.dmcourse mc on mpm.courseid = mc.courseid      
order by mpm.rank, mpm.CourseID      
*/      
      
      
/*      
-- If Preranked.. then load like this..      
----------------------------------------      
select * from datawarehouse.mapping.WebLP_InputCourse      
      
truncate table datawarehouse.mapping.WebLP_InputCourse      
      
insert into mapping.WebLP_InputCourse values (1564,1)      
insert into mapping.WebLP_InputCourse values (1637,2)      
insert into mapping.WebLP_InputCourse values (1950,3)      
insert into mapping.WebLP_InputCourse values (1970,4)      
insert into mapping.WebLP_InputCourse values (1933,5)      
insert into mapping.WebLP_InputCourse values (7901,6)      
      
      
-- Check the course list..      
select MPM.CourseID, MC.CourseName, MC.SubjectCategory2, BundleFlag, mpm.rank      
FROM datawarehouse.mapping.WebLP_InputCourse mpm JOIN      
 DataWarehouse.Mapping.dmcourse mc on mpm.courseid = mc.courseid      
order by mpm.rank      
*/      
      
--run the procedure      
      
/*      
Procedure info:      
[Staging].[CreateWebLandingPageData]      
 @LogicName varchar(20) = 'RankBySales',      
 @Months int = 12,      
 @Country varchar(5) = 'US',      
 @Name varchar(15) = 'Gen',      
 @StartDate date = null,      
 @CampaignExpire date = null,      
 @LPID int = 0      
*/       
      
--Example:      
--exec [Staging].[CreateWebLandingPageData] 'Email/Web','TypeOfRanking', Months, 'CountryCode', 'NameofLandingPage', 'StartDate', 'ExprnDate', LPID      
--exec [Staging].[CreateWebLandingPageData] 'Email', 'RankBySales', 12, 'US', 'SrprsSvngs', '9/10/2014', '9/21/2014',88      
--exec [Staging].[CreateWebLandingPageData] 'Email', 'RankByOrders', 3, 'AU', 'BLMagTEST', '9/10/2014', '9/21/2014',75      
--exec [Staging].[CreateWebLandingPageData] 'Email', 'PreRank', null, 'AU', 'PreRankTEST', '9/10/2014', '9/21/2014',65      
      
      
Begin Tran      
      
      
      
      
declare @PrefID  varchar(2)      
select @PrefID = ''     
      
      
print '@Prefid'      
select @Prefid      
      
      
exec [Staging].[CreateWebLandingPageData_CYC] 'Email', 'RankBySales', 12, @countrycd, @emailid, @startdate, @stopdate,@PrefID      
--exec [Staging].[CreateWebLandingPageData] 'Email', 'PreRank', null, 'AU', 'PreRankTEST', '9/10/2014', '9/21/2014',65      
      
set @tablenm = 'WebLP_' + @countrycd +'_' + convert(char(8),@startdate , 112) + '_' + @emailid + '_CourseRank'      
-- Final table is created on lstmgr with this naming convention      
-- lstmgr..WebLP_AU_20150325_AUFebSetsDLR_CourseRank      
-- %15%      
      
print 'table nm'      
select @tablenm      
      
      
--qc1      
set @SQL =  '  Print ''qc1''      
   select preferredcategory, COUNT(*)       
   from Lstmgr..'+ @tablenm +      
   ' group by preferredcategory      
   order by 1'      
exec (@SQL)      
      
if OBJECT_ID('datawarehouse.mapping.WebLP_InputCourse_temp') is not null      
drop table datawarehouse.mapping.WebLP_InputCourse_temp      
      
set @SQL =  '  Print ''Into datawarehouse.mapping.WebLP_InputCourse_temp''      
   select preferredcategory, COUNT(*) cnt into datawarehouse.mapping.WebLP_InputCourse_temp      
   from Lstmgr..'+ @tablenm  + ' group by preferredcategory '      
exec (@SQL)      
      
      
      
select @matchcount = isnull(min(Cnt),0)       
from datawarehouse.mapping.WebLP_InputCourse_temp      
  
      
select @matchcount as rankingCNT,@count InitialCNT      
If @matchcount<@count      
begin      
      
Print 'Missing CourseIDs'      
  
set @SQL = ' select * from datawarehouse.mapping.WebLP_InputCourse  where Courseid not in (select distinct Courseid  from Lstmgr..'+ @tablenm +' )'   
exec (@SQL)  
  
--select a.* from datawarehouse.mapping.WebLP_InputCourse a      
--left join datawarehouse.mapping.WebLP_InputCourse_temp t      
--on A.CourseID=t.CourseID      
--where t.CourseID is null      
      
RAISERROR (N'There are less counts in the course counts for landing page after the ranking.', 10, 1 )      
      
rollback tran      
Return      
end      
      
--else commit      
commit tran      
      
      
if OBJECT_ID('datawarehouse.mapping.WebLP_InputCourse_temp') is not null      
drop table datawarehouse.mapping.WebLP_InputCourse_temp      
      
-- Check ranking      
set @SQL = ' print ''Check ranking''      
   select * from lstmgr..'+ @tablenm +        
   ' order by preferredcategory, rank '      
exec (@SQL)      
      
set @SQL =  ' Print ''Basic QC''      
   select a.SumSales, a.TotalOrders, a.CourseID, b.CourseName, b.CourseParts,       
   a.PreferredCategory, a.Rank, a.FlagBundle, a.CampaignExpireDate, a.blnMarkdown, a.Message      
   from lstmgr..' + @tablenm + '  a join      
   DataWarehouse.Mapping.DMCourse b on a.courseid = b.CourseID      
   order by a.rank '      
exec (@SQL)      
      
      
-- Update BlnMarkDown or Message if needed.      
set @sql = 'update a       
   set a.blnMarkdown = LP.blnMarkdown,      
    a.message = LP.message      
   from lstmgr..'+ @tablenm + ' a       
   inner join DataWarehouse.Mapping.email_landingpage LP      
   on LP.CourseID = a.CourseID      
   where LP.EmailID = ''' + @emailid + ''''      
      
exec (@sql)      
  
  
-- Float %off Messaging Courses on top.  
    
set @sql = 'update a       
   set Rank = Rank/ ('+ cast(@count as varchar(5))+'/11.33)  
   from lstmgr..'+ @tablenm + ' a       
   inner join DataWarehouse.Mapping.email_landingpage LP      
   on LP.CourseID = a.CourseID      
   where LP.EmailID = ''' + @emailid + '''  
   and LP.Message like ''%[%]%'''      
     
   print @sql  
     
   exec (@sql)  
  
---new landing page process      
/* 
print 'new landing page process'      
select * from reports..mktwebcategorycourses      

     
print 'new landing page process by category Id'      
select CategoryID, COUNT(*)       
from reports..mktwebcategorycourses      
group by CategoryID      
order by 1      

Set @SQL = 'insert into reports..mktwebcategorycourses        
   select PreferredCategory as CategoryID,       
    CourseID,      
    RANK as DisplayOrder,      
    blnMarkdown,      
    Message,      
    CampaignExpireDate as Expires      
    from LStmgr.dbo.' + @tablenm +'       
   order by 1,3'      
exec (@SQL)      
      
print 'Inserted mktwebcategorycourses ordered by rank'      
select * from reports..mktwebcategorycourses      
order by 3      
      
      
print 'Count records from mktwebcategorycourses by CategoryID'      
select CategoryID, COUNT(*)       
from reports..mktwebcategorycourses      
group by CategoryID      
order by 1      
      
--now QC the reports..mktwebcategorycourses table      
*/      
/*
      
--Final update to EmailPull       
declare @FnlActiveTable varchar(200),@FnlSNITable varchar(200) ,@FnlPRSPCTTable varchar(200)      
      
set @FnlActiveTable= @emailid +'_NEW_Active'      
set @FnlSNITable= @emailid +'_NEW_SNI'  
set @FnlPRSPCTTable = @emailid +'_PRSPCT'   
      
if exists(select * from lstmgr.sys.tables where name = @FnlActiveTable)      
begin      
      
set @sql = 'update lstmgr..' + @FnlActiveTable +     
   ' set PreferredCategory = REPLACE(PreferredCategory,'' '','''') + CAST( ' + @PrefID + ' as varchar(2)) '      
exec (@sql)      
      
End      
      
if exists(select * from lstmgr.sys.tables where name = @FnlSNITable)      
begin      
      
set @sql = 'update lstmgr..' + @FnlSNITable +       
    ' set PreferredCategory = REPLACE(PreferredCategory,'' '','''') + CAST( '+ @PrefID + ' as varchar(2)) '      
exec (@sql)      
      
End      


if exists(select * from lstmgr.sys.tables where name = @FnlPRSPCTTable)      
begin      
      
set @sql = 'update lstmgr..' + @FnlPRSPCTTable +       
    ' set PreferredCategory = REPLACE(PreferredCategory,'' '','''') + CAST( '+ @PrefID + ' as varchar(2)) '      
exec (@sql)      
      
End            
       */
      
/*      
      
-- to JIRA TICKET      
      
print 'JIRA TICKET'      
Print 'Hi,      
I have appended the ranking table to reports..mktwebcategorycourses on TTCDatamart01.       
Please confirm when the table gets loaded to production.      
      
Here is my qc:      
'      
      
set @SQL = '      
select a.CategoryID, a.Expires, COUNT(a.CourseID) as CourseCount from      
reports..mktwebcategorycourses a join      
 (select distinct preferredcategory as categoryID      
 from  LStmgr.dbo.'+ @tablenm +' )b on a.categoryid = b.categoryID      
group by a.CategoryID, Expires      
order by 1'      
      
Print (@SQL)      
Print ''      
Exec (@SQL)      
      
set @SQL = '      
select preferredcategory as categoryid, CampaignExpireDate, COUNT(*) as coursecount      
from LStmgr.dbo.'+ @tablenm +'       
group by preferredcategory, CampaignExpireDate      
order by preferredcategory'      
      
Print (@SQL)      
Print ''      
Exec (@SQL)      
      
Print 'Thanks,'      
Print 'Vikram'      
*/      
      
end  
  
  
  
  
  
GO
