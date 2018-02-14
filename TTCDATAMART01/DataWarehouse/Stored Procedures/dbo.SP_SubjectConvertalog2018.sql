SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_SubjectConvertalog2018]     @RunSecondPortion bit = 0   
as        
Begin        
        
declare @AcquisitionWeek  Date =  DATEADD(wk, DATEDIFF(wk, 6, GETDATE() ), 0) -- LastWeekMonday        
declare @CutoffDay Date = dateAdd(dd,6,@AcquisitionWeek)-- NextWeekSunday        
declare @MinMilingCnt int = 200        
declare @StartDate Date          
declare @CurrentWeekMondayID varchar(20) = convert(char(8), @AcquisitionWeek, 112)            
declare @SQL nvarchar(4000)      
declare @StopMonth varchar(20)      
      
    
if OBJECT_ID ('Datawarehouse.Staging.SubAdcodeConvertalog') is not null        
Drop table Datawarehouse.Staging.SubAdcodeConvertalog        
        
 /* Adcodes */        
 select *        
 into Datawarehouse.Staging.SubAdcodeConvertalog        
 from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid        
 where EmailType = 'SubjConvertalog'        
 and AcquisitionWeek =@AcquisitionWeek        
 order by AcquisitionWeek, Adcode        
        
        
select @StartDate = cast(isnull(MIN(Startdate),@AcquisitionWeek) as DATE),      
@StopMonth = Upper(CAST( DATENAME(MM, min(Startdate) ) as Varchar(3)))      
from DataWarehouse.Mapping.vwAdcodesAll        
where AdCode in (select AdCode from Datawarehouse.Staging.SubAdcodeConvertalog)        
      
select @AcquisitionWeek as AcquisitionWeek,@CutoffDay as CutoffDay ,@StartDate as StartDate, @CurrentWeekMondayID as CurrentWeekMondayID,@CurrentWeekMondayID as CurrentWeekMondayID


select * from Datawarehouse.Staging.SubAdcodeConvertalog
          
If @RunSecondPortion = 0 

Begin        

				if OBJECT_ID ('Datawarehouse.Staging.SubConvertalog') is not null        
				Drop table Datawarehouse.Staging.SubConvertalog        
        
				  SELECT CCS.CustomerID, CCS.BuyerType, CCS.NewSeg, CCS.Name,         
				   CCS.a12mf, CCS.ComboID, CCS.Concatenated Concantonated,        
				   CCS.CustomerSegment, CCS.Frequency, CCS.FMPullDate, @StartDate as StartDate,         
				   CCS.Prefix, CCS.FirstName, CCS.MiddleName MiddleInitial, CCS.LastName, CCS.Suffix,         
				   CCS.CompanyName as Company,         
				   ccs.Address1 + ' '  + ccs.Address2 as Address1,        
				   ccs.Address3 as Address2, CCS.City, CCS.State, CCS.PostalCode,        
				   CCS.AH, CCS.EC, CCS.FA, CCS.HS, CCS.LIT, CCS.MH, CCS.PH, CCS.RL, CCS.SC,         
				   CCS.FlagMail, CCS.PreferredCategory, isnull(CCS.PreferredCategory2,'FW')PreferredCategory2, CCS.PublicLibrary,        
				   CCS.FlagValidRegionUS FlagValidRegion, DMCS.IntlPurchaseDate, 0 as FlagWelcomeBack,cast(null as varchar(50))SubjectLong2         
				   ,cast(0 as int) AdCode
				   --,isnull(NCWS.CustGroup,'CONTROL')CustGroup
				   ,replace(isnull(NCWS.CustGroup,'CONTROL'),'TEST','CONTROL')CustGroup /*Added to include both test and Control*/
				   ,Isnull(NCWS.HVLVGroup,'HV')HVLVGroup,CAST( null as Varchar(25))ConvertalogSubjectcat        
				  INTO Datawarehouse.Staging.SubConvertalog        
				  FROM  Datawarehouse.Marketing.campaigncustomersignature CCS left outer join        
				   (select CustomerID, OrderID, DateOrdered as IntlPurchaseDate        
				   from DataWarehouse.Marketing.DMPurchaseOrders        
				   where SequenceNum = 1)dmcs on CCS.CustomerID = dmcs.CustomerID        
				   left join [DataWarehouse].[Marketing].[NewCustomerWelcomeSeries] NCWS        
				   on ncws.CustomerID = CCS.CustomerID        
				  WHERE CCS.FlagMail = 1 AND CCS.PublicLibrary = 0 AND CCS.FlagValidRegionUS = 1        
				  AND ISNULL(CCS.Frequency,'F1') = 'F1'        
				  and DMCS.IntlPurchaseDate >= DATEADD(month,-2,GETDATE())        
        
				/*Delete Previous Sent Customers*/        
				delete a        
				from Datawarehouse.Staging.SubConvertalog a join        
				 Datawarehouse.Archive.MailingHistory_Convertalog b on a.customerid = b.Customerid  join        
				 DataWarehouse.Mapping.vwAdcodesAll c on b.AdCode = c.AdCode        
				where c.MD_CampaignName not like '%Best%Seller%'         
				and c.MD_CampaignName not like '%top%rated%'      
				/*Removed code for duplicates issue 2015/12/15*/      
				/*    
				and c.StartDate >= (select MAX(M.startdate) Startdate         
					   from DataWarehouse.Archive.MailingHistory_Convertalog M     
					   left join DataWarehouse.Mapping.vwAdcodesAll c on M.AdCode = c.AdCode        
					   where c.MD_CampaignName not like '%Best%Seller%' and c.MD_CampaignName not like '%top%rated%'        
					   )        
				*/        
        
				/*Delete Customers as these will be sent next time */        
				 delete a        
				from Datawarehouse.Staging.SubConvertalog a join        
				 Datawarehouse.Marketing.campaigncustomersignature b on a.customerid = b.customerid        
				where b.customersince >= @CutoffDay        
        
        
				--/* Defaulted if it doesn't exist*/        
				--  update C        
				--  set PreferredCategory2 = isnull(PreferredCategory2,'FW')         
				--  from Datawarehouse.Staging.SubConvertalog C        
				--  where PreferredCategory2 is null        
        
         
				/* Update SubjectLong2*/        
				  --update C        
				  --set SubjectLong2 = isnull(SL.SubjectLong2,'Health & Wellness')         
				  --from Datawarehouse.Staging.SubConvertalog C        
				  --left join [Staging].vwCustomerSubjectCategorySubjectLong2 SL        
				  --on SL.Customerid = C.CustomerID         
				  --where SL.RankNum = 1        
        
				/* Defaulted if it doesn't exist*/        
				  --update C        
				  --set SubjectLong2 = isnull(SubjectLong2,'Health & Wellness')         
				  --from Datawarehouse.Staging.SubConvertalog C        
				  --where SubjectLong2 is null        
        
        
        
				/*Update Customer group with Test if it exists*/        
         
				If exists (select 1 from  Datawarehouse.Staging.SubAdcodeConvertalog where CustGroup = 'Test')        
        
				  Begin         
        
				  select   isnull(PreferredCategory2,'FW')PreferredCategory2 , isnull(HVLVGroup,'HV')HVLVGroup,COUNT(*) CNT,cast(0 as int) Processed          
				  Into #Split        
				  from    Datawarehouse.Staging.SubConvertalog        
				  group by   isnull(PreferredCategory2,'FW'), isnull(HVLVGroup,'HV')        
        
        
				  Declare @PreferredCategory2 varchar(50), @HVLVGroup varchar(10),@Cnt varchar(10)--, @SQL nvarchar(2000)        
				 /*Update Customer group with Test if it exists by splitting customers by PreferredCategory2 and HVLV*/        
					while exists (select top 1 PreferredCategory2 from #Split where Processed = 0)        
					begin        
        
					select top 1 @PreferredCategory2  = PreferredCategory2, @HVLVGroup = HVLVGroup ,@Cnt = cast(CNT/2 as int)        
					from #Split where Processed = 0        
        
					set @SQL =        
					'update Datawarehouse.Staging.SubConvertalog        
					set CustGroup = ''TEST''        
					where CustomerID in         
					( select top ' + @Cnt + ' customerid from Datawarehouse.Staging.SubConvertalog 
					where isnull(PreferredCategory2,''FW'')  = ''' 
					+@PreferredCategory2 +''' and  isnull(HVLVGroup,''HV'') = ''' + @HVLVGroup  + ''' 
					order by newid()
					) '        
        
					exec (@SQL)        
        
					update  #Split         
					set Processed = 1        
					where PreferredCategory2 = @PreferredCategory2 and HVLVGroup = @HVLVGroup        
        
					end        
        
				  End              
        
				/*        
				print 'Splits'        
				select ComboID, isnull(HVLVGroup,'HV'),custgroup, COUNT(*) from Datawarehouse.Staging.SubConvertalog        
				group by ComboID, isnull(HVLVGroup,'HV'),custgroup        
				order by 1,2        
        
        
				print 'Splits'        
				select ComboID, custgroup, COUNT(*) from Datawarehouse.Staging.SubConvertalog        
				group by ComboID,  custgroup        
				order by 1,2        
				*/        
         
         
        
         
				/*Update  Control*/        
				--Update C        
				--set AdCode = AD.Adcode,        
				--ConvertalogSubjectcat = Subcat.ConvertalogSubjectCat        
				--from Datawarehouse.Staging.SubConvertalog C        
				--inner join Mapping.Vw_ConvertalogSubjectCat Subcat         
				--on PreferredCategory2 = Subcat.ConvertalogSubject        
				--and C.CustGroup = Subcat.CustGroup        
				--inner join Datawarehouse.Staging.SubAdcodeConvertalog Ad         
				--on Ad.ConvertalogSubjects = SubCat.ConvertalogSubjectcat        
				--and c.HVLVGroup = Ad.HVLVGroup        
				--where c.CustGroup = 'CONTROL'         
        
        
 				Update C        
				set AdCode = AD.Adcode,        
				ConvertalogSubjectcat = 'Tabloid'     
				from Datawarehouse.Staging.SubConvertalog C        
				inner join Datawarehouse.Staging.SubAdcodeConvertalog Ad         
				on Ad.CustGroup = C.CustGroup       
				and c.HVLVGroup = Ad.HVLVGroup        
				where c.CustGroup = 'CONTROL'                
        
				/*Update  Test*/        
 
      
        
        
				Print 'Inventory less than 20'        
				select c.adcode,A.adcodename,c.CustGroup,inv.versionname,inv.qty,COUNT(customerid) ,inv.qty - COUNT(customerid)           
				from Datawarehouse.Staging.SubConvertalog c        
				left join Mapping.ConvertalogInventory Inv        
				on c.ConvertalogSubjectCat  = Inv.ConvertalogSubjectCat        
				and c.HVLVGroup = inv.hvlvgroup        
				left join DataWarehouse.Mapping.WelcomeEmailAdcodeGrid A        
				on a.Adcode = c.AdCode        
				group by c.adcode,A.adcodename,c.CustGroup,inv.versionname,inv.qty        
				having  inv.qty - COUNT(customerid)  <20        
				order by 6        
        
				Print 'Counts Less than 195 + 5 seed for 200 min'       
				select c.adcode,A.adcodename,c.CustGroup,inv.versionname,inv.qty,COUNT(customerid) CustomerCnt ,inv.qty - COUNT(customerid) InventoryCnt          
				from Datawarehouse.Staging.SubConvertalog c        
				left join Mapping.ConvertalogInventory Inv        
				on c.ConvertalogSubjectCat  = Inv.ConvertalogSubjectCat        
				and c.HVLVGroup = inv.hvlvgroup        
				left join DataWarehouse.Mapping.WelcomeEmailAdcodeGrid A        
				on a.Adcode = c.AdCode        
				group by c.adcode,A.adcodename,c.CustGroup,inv.versionname,inv.qty        
				having COUNT(customerid) < 195       
				order by 6        
        
        
				/* Customer Cnts that are less than Minimum Category Mailing*/        
         
				--declare @adcode int  ,@mailingCnt int ,@CustGroup varchar(20)        
        
				If exists         
				(        
				select a.adcode,a.AdcodeName,c.CustGroup,c.HVLVGroup,COUNT(*) from Datawarehouse.Staging.SubConvertalog c        
				left join Datawarehouse.Staging.SubAdcodeConvertalog a        
				on a.Adcode=c.AdCode        
				group by a.AdCode  ,a.AdcodeName,c.CustGroup,c.HVLVGroup        
				having COUNT(customerid) <195        
				)        
        
				Begin         
        
				select 'Counts Less than 193 + 7 seed for 200 min'        
        
				--select  a.adcode, c.CustGroup , COUNT(*) from Datawarehouse.Staging.SubConvertalog c        
				--left join Datawarehouse.Staging.SubAdcodeConvertalog a        
				--on a.Adcode=c.AdCode        
				--group by a.AdCode  ,a.AdcodeName,c.CustGroup,c.HVLVGroup        
				--having COUNT(customerid) <193      
  
				Print 'Only First portion has been run, need to manually 
				Move Customer Cnts that are less than Minimum Category Mailing
				 '
				Return 0
				END        
        


End  /*End @RunSecondPortion = 0 */       
        
If @RunSecondPortion = 1

Begin        
select C.HVLVGroup, C.ConvertalogSubjectcat        
,COUNT(*)         
from Datawarehouse.Staging.SubConvertalog c        
left join Datawarehouse.Staging.SubAdcodeConvertalog a        
on a.Adcode=c.AdCode        
--where c.CustGroup = 'test'       
group by C.HVLVGroup, C.ConvertalogSubjectcat        
order by 2,1        
        
SELECT A.PreferredCategory2,CustGroup, a.adcode, FlagWelcomeBack, count(a.customerid)        
from  Datawarehouse.Staging.SubConvertalog a         
group by A.PreferredCategory2,CustGroup, a.adcode, FlagWelcomeBack        
order by 3,1,2        
        
        
SELECT A.PreferredCategory2,CustGroup, a.adcode, c.adcodeName, c.CatalogCode, c.CatalogName, FlagWelcomeBack, count(a.customerid)        
from  Datawarehouse.Staging.SubConvertalog a left join        
 DataWarehouse.Mapping.vwAdcodesAll c on a.Adcode = c.adcode        
group by A.PreferredCategory2,CustGroup, a.adcode, c.adcodeName, c.CatalogCode, c.CatalogName, FlagWelcomeBack        
order by 4,1,2        

         
if OBJECT_ID ('Datawarehouse.Staging.SubConvertalogFinal') is not null        
Drop table Datawarehouse.Staging.SubConvertalogFinal        
        
SELECT Convert(varchar(150),        
 Ltrim(rtrim(Prefix + ' ' + FirstName + ' ' + LastName + ' ' + Suffix))) FullName1,        
 Company as Company1, Address1 as Altrntddr1,        
 Address2 AltrntAddr2,         
 convert(varchar(250),'') DLVRYDDRSS, City, State, PostalCode as Zip4,         
 a.AdCode as ConvertalogAdcode,         
 CustomerID,-- convert(varchar(50),'THURSDAY AUG 27, 2015') Expire,         
 cast(Upper(DATENAME(DW, b.StopDate ) )+ ' ' +Upper(CAST( DATENAME(MM, b.StopDate ) as Varchar(3))) + RIGHT(CONVERT(VARCHAR(12), b.StopDate , 107), 9) as varchar(50))  Expire,        
 convert(varchar(25),REPLACE(inv.ConvertalogSubjectCat,',','_') + case when inv.HVLVGroup  = 'HV' Then ' PM4'         
                    when inv.HVLVGroup  = 'MV' Then ' PM5'         
                    when inv.HVLVGroup  = 'LV' Then ' PM8'         
                    else ' PM4' end) as VersionName        
 INTO Datawarehouse.Staging.SubConvertalogFinal        
from  Datawarehouse.Staging.SubConvertalog a left join        
 DataWarehouse.Mapping.vwAdcodesAll b on a.AdCode = b.AdCode        
 left join Mapping.ConvertalogInventory inv        
 on a.ConvertalogSubjectCat = inv.ConvertalogSubjectCat and a.HVLVGroup = Inv.HVLVGroup        
where a.AdCode > 0        
         
        
--select * from Datawarehouse.Staging.SubConvertalogFinal        
        
/* Insert Seeds */        
        
insert into Datawarehouse.Staging.SubConvertalogFinal        
select a.FullName1, '', a.Altrntddr1, '', '', a.City, a.State, a.Zip4,        
 b.ConvertalogAdcode, 99999999 as CustomerID,        
 b.Expire, b.VersionName        
from Datawarehouse.Mapping.SeedNames_Convertalog a,        
 (select distinct convertalogadcode, expire, VersionName        
 from  Datawarehouse.Staging.SubConvertalogFinal)b        
        
      
select convertalogadcode ,COUNT(*) from Datawarehouse.Staging.SubConvertalogFinal        
group by convertalogadcode        
order by 2        
        
        
select ConvertalogAdcode, COUNT(customerID)         
from Datawarehouse.Staging.SubConvertalogFinal        
where CustomerID = 99999999        
group by ConvertalogAdcode        
        
--delete from Datawarehouse.Staging.SubConvertalogFinal        
--where CustomerID = 99999999        
        
        
update  Datawarehouse.Staging.SubConvertalogFinal        
set Altrntddr1 = replace(replace(ISNULL(Altrntddr1,''),char(13),''),char(10),''),        
 AltrntAddr2 = replace(replace(ISNULL(AltrntAddr2,''),char(13),''),char(10),''),        
 company1 = replace(replace(ISNULL(company1,''),char(13),''),char(10),'')        
        
        
update  Datawarehouse.Staging.SubConvertalogFinal        
set Altrntddr1 = replace(Altrntddr1,'|',''),        
 AltrntAddr2 = replace(AltrntAddr2,'|',''),        
 company1 = replace(company1,'|','')        
        
        
select * from Datawarehouse.Staging.SubConvertalogFinal        
where fullname1 like '%-%'        
        
        
update Datawarehouse.Staging.SubConvertalogFinal        
set fullname1 =REPLACE(fullname1,'-','')        
        
/*Updating due to quotes issue('"') causing textqualifier issues.  */      
      
Update  DataWarehouse.Staging.SubConvertalogFinal      
set FullName1 = Case when FullName1 like '"%'       
      then REPLACE (FullName1,'"','')       
      else FullName1 end,      
 Company1 = Case when Company1 like '"%'       
      then REPLACE (Company1,'"','')       
      else Company1 end,      
    Altrntddr1 = Case when Altrntddr1 like '"%'       
      then REPLACE (Altrntddr1,'"','')       
      else Altrntddr1 end,      
 AltrntAddr2 = Case when AltrntAddr2 like '"%'       
      then REPLACE (AltrntAddr2,'"','')       
      else AltrntAddr2 end,       
 DLVRYDDRSS = Case when DLVRYDDRSS like '"%'       
      then REPLACE (DLVRYDDRSS,'"','')       
      else DLVRYDDRSS end,      
    City = Case when City like '"%'       
      then REPLACE (City,'"','')       
      else City end,      
 State = Case when State like '"%'       
      then REPLACE (State,'"','')       
      else State end ,      
    CustomerID = Case when CustomerID like '"%'       
      then REPLACE (CustomerID,'"','')       
      else CustomerID end,      
 Zip4 = Case when Zip4 like '"%'       
      then REPLACE (Zip4,'"','')       
      else Zip4 end        
where FullName1 like '"%' OR Company1 like '"%' OR Altrntddr1 like '"%' OR AltrntAddr2 like '"%'       
OR DLVRYDDRSS like '"%' OR City like '"%' OR State like '"%' OR CustomerID like '"%' OR Zip4 like '"%'             
        
       
        
-- Final QC #1        
print 'Final QC #1  '      
SELECT A.PreferredCategory2, a.adcode, c.adcodeName, FlagWelcomeBack,  count(a.customerid)        
from  Datawarehouse.Staging.SubConvertalog a left join        
 datawarehouse.mapping.vwadcodesall c on a.Adcode = c.adcode        
-- where A.PreferredCategory2 in ('EC','HS','X')        
group by A.PreferredCategory2, a.adcode, c.adcodeName, FlagWelcomeBack        
order by 5, 4,2,1        
        
       
        
        
-- Final QC #2        
Print 'Final QC #2'      
SELECT A.VersionName, a.ConvertalogAdcode, c.adcodeName, count(distinct a.customerid)        
from  Datawarehouse.Staging.SubConvertalogFinal  a left join        
 datawarehouse.mapping.vwadcodesall c on a.ConvertalogAdcode = c.adcode      where customerid < 99999999        
group by A.VersionName, a.ConvertalogAdcode, c.adcodeName        
order by 2        
        
        
      
-- Final QC #3        
Print 'Final QC #3'      
select convert(datetime,Convert(varchar,b.CustomerSince,101)) CustomerSince,         
 Count(distinct a.customerid) CustCount        
from Datawarehouse.Staging.SubConvertalog a join        
 Datawarehouse.Marketing.campaigncustomersignature b on a.customerid = b.customerid        
--where a.adcode in (43649, 43758)        
group by convert(datetime,Convert(varchar,b.CustomerSince,101))        
--having COUNT(distinct a.customerid) > 10        
order by 1 desc,2        
        
-- Final QC #4        
Print 'Final QC #4'        
select convert(datetime,Convert(varchar,b.CustomerSince,101)) CustomerSince,         
 a.FlagWelcomeBack,        
 Count(a.customerid) CustCount        
from Datawarehouse.Staging.SubConvertalog a join        
 Datawarehouse.Marketing.campaigncustomersignature b on a.customerid = b.customerid        
--where a.adcode in (43649, 43758)        
group by convert(datetime,Convert(varchar,b.CustomerSince,101)), a.FlagWelcomeBack        
--having COUNT(distinct a.customerid) > 10        
order by 1 desc,2        
        
      
set @SQL = '          
  if object_id (''rfm.dbo.'+ @StopMonth +'_SubConvertalog_'+ @CurrentWeekMondayID + '_Quad'') is not null            
     Drop table rfm.dbo.'+ @StopMonth +'_SubConvertalog_'+ @CurrentWeekMondayID + '_Quad             
     select * into rfm.dbo.'+ @StopMonth +'_SubConvertalog_' + @CurrentWeekMondayID + '_Quad  from Datawarehouse.staging.SubConvertalogFinal'         
exec (@SQL)          
      
set   @SQL = 'exec staging.ExportTableToPipeText rfm, dbo,' + @StopMonth + '_SubConvertalog_' + @CurrentWeekMondayID + '_Quad, ''\\File1\Groups\Marketing\MailFiles\2018\US\Convertalog'''       
exec (@SQL)       
        
        
/* Insert into History*/        
        
       


insert into Datawarehouse.Archive.MailingHistory_Convertalog  
select s.customerid, s.adcode, s.startdate, s.NewSeg, s.Name, s.A12mf,         
 s.Concantonated, 0, s.ComboID, '', s.PreferredCategory2        
from Datawarehouse.Staging.SubConvertalog    S    
left join Datawarehouse.Archive.MailingHistory_Convertalog h
on h.CustomerID=s.CustomerID and h.AdCode=s.AdCode
where s.customerid <> 99999999      
and H.customerid is null


      
--Update Counts for Inventory!!!      
      
        
Update INV      
set INV.QTY = INV.QTY-CNT       
--select INV.QTY,CNT, INV.QTY-CNT ,FNl.VersionName      
from Mapping.ConvertalogInventory Inv        
inner join (select VersionName,COUNT(*) CNT      
 from Datawarehouse.Staging.SubConvertalogfinal         
 group by VersionName)  Fnl      
on convert(varchar(25),REPLACE(inv.ConvertalogSubjectCat,',','_') +       
case when inv.HVLVGroup  = 'HV' Then ' PM4'         
     when inv.HVLVGroup  = 'MV' Then ' PM5'         
     when inv.HVLVGroup  = 'LV' Then ' PM8'         
     else ' PM4' end) = Fnl.VersionName      
      
            
Print 'Final QC'      
      
set @SQL = 'select Convertalogadcode,b.AdcodeName,COUNT(*) from rfm..'+ @StopMonth +'_SubConvertalog_'+ @CurrentWeekMondayID + '_quad A      
left join DataWarehouse.Mapping.vwAdcodesAll B      
on b.AdCode = a.Convertalogadcode      
group by Convertalogadcode,b.AdcodeName      
order by 3'      
      
exec (@SQL)      
      
      
print 'Subject Convertalog Data For the Month of ' + @StopMonth          
print '==================================================='          
print ''          
print 'Zip: ' + @StopMonth +'_SubConvertalog_' + @CurrentWeekMondayID +'_Quad.zip'          
print ''          
print 'File: ' + @StopMonth +'_SubConvertalog_' + @CurrentWeekMondayID +'_Quad.txt'          
print ''          
      
      
 set @SQL = 'select count(*) TotalRecords          
   from rfm.dbo.'+ @StopMonth +'_SubConvertalog_' + @CurrentWeekMondayID + '_Quad'          
Exec (@SQL)         

end
        
End        







GO
