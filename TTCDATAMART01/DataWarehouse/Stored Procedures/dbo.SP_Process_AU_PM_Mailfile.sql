SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
          
CREATE proc [dbo].[SP_Process_AU_PM_Mailfile]          
as          
BEGIN          
          
declare @table_nm varchar(200), @subjectFlg bit            
          
 /*Truncate working table*/          
 Truncate table [Archive].[ToMH_PM_MailFile]          
          
 /*  delete invalid customerids*/           
 delete from [Archive].[ToMH_PM_MailFile_test]          
 where CustomerID is null or CustomerID=''          
          
 /*  delete for customerid 12345678 */            
 delete from datawarehouse.archive.ToMH_PM_MailFile_test            
 where CustomerID in (12345678)            
                
            
 update a          
 set  adcode = cast(replace(adcode,'Priority Code: ','') as int)          
 from [Archive].[ToMH_PM_MailFile_test] a          
            
          
 /*  delete invalid adcodes*/            
 delete from datawarehouse.archive.ToMH_PM_MailFile_test            
 where adcode in (99993,99994,99995,99996,99997,99998,99999,11844,12205,12345)            
               
  select @table_nm = map.TableNm ,@subjectFlg = SubjectFlag             
  from Mapping.MailHistoryPMCountrySubjectAdcode map (nolock)            
  inner join ( select top 1 adcode             
  from datawarehouse.archive.ToMH_PM_MailFile_test            
  where adcode in             
  (select distinct adcode from Mapping.MailHistoryPMCountrySubjectAdcode map (nolock)             
  where countrycd='AU' and map.PMUpdateflag=0 )) PM             
  on pm.adcode=map.adcode            
  where map.PMUpdateflag=0 and map.CountryCd = 'AU'             
            
          
          
if @table_nm is not null            
            
   Begin            
            
          
  insert into [Archive].[ToMH_PM_MailFile] (CustomerID,adcode)          
  select distinct a.Customerid, a.adcode          
  from [Archive].[ToMH_PM_MailFile_test] A               
            
       if @subjectFlg=0            
       begin            
            
       /*If it is a non subject mailing then run this*/            
            
       exec [Staging].[UpdateMailHistory] @table_nm            
       exec [Staging].[UpdateMailHistoryThisYear] @table_nm            
            
       /*Update mapping table to set PMFlag to complete*/            
         update Map            
         set PMUpdateflag=1            
         from Mapping.MailHistoryPMCountrySubjectAdcode map (nolock)            
         where TableNm = @table_nm             
            
       end            
            
            
       if @subjectFlg=1            
       begin            
            
       /*If it is a subject mailing like magazine/subject magalog then run this*/            
            
       exec [Staging].[UpdateMailHistory] @table_nm,'Y'            
       exec [Staging].[UpdateMailHistoryThisYear] @table_nm,'Y'            
            
       /*Update mapping table to set PMFlag to complete*/            
         update Map            
         set PMUpdateflag=1            
         from Mapping.MailHistoryPMCountrySubjectAdcode map (nolock)            
         where TableNm = @table_nm             
            
       end            
         
        
  declare @sql varchar(1000)      
      
/*Update Tracking Table*/    
    
set @sql =     
' insert into Datawarehouse.archive.PMHistory  
    
 select MailHistoryPMCountrySubjectAdcodeID,a.*,b.*,H.HistoryCnts,GETDATE() as Updateddate     
  from Mapping.MailHistoryPMCountrySubjectAdcode map (nolock)    
  Inner join (select  '''+ @table_nm + ''' as TableNm ,adcode,COUNT(*) InitialCnts from rfm..'+@table_nm+'    
     where adcode>0    
     group by adcode)a    
   on map.TableNm = a.TableNm    
  left join     
     (select adcode as PMAdcode,count(*) as PMCnts from datawarehouse.archive.ToMH_PM_MailFile_test     
     where adcode>0    
     group by adcode )b     
   on a.adcode= b.PMAdcode    
  left join     
     (select adcode as HisAdcode,count(*) as HistoryCnts from datawarehouse.archive.MailhistoryCurrentYear     
     where adcode>0    
     group by adcode )H     
   on a.adcode= H.HisAdcode'       
    
exec (@sql)    
         
   End            
          
          
END 
GO
