SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
                
CREATE View [Archive].[Vw_Subscription_Weekly]                
as                
                
--Registrations DRTV               
select 'TELE' as Telemarketer,                
      4732826877 as TollFreeNum,                
      convert(varchar,joined,112) as Date,                
      replace(CONVERT(VARCHAR(5), Joined, 108),':','') AS MilitaryTime,                
      --joined,                
      'REGS' as Response,                
      RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6) TotalCounts,                
      CONVERT(char(6),'      ') as DNISCode,                
      CONVERT(char(5),'     ') as ZIP,                
      CONVERT(char(3),'999') as AreaCode,                
      'TELE' + '4732826877' + convert(varchar,joined,112)+replace(CONVERT(VARCHAR(5), Joined, 108),':','')+'REGS'+RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6)+                
      CONVERT(char(6),'      ')+CONVERT(char(5),'     ')+CONVERT(char(3),'999') as Output                
from DataWarehouse.Archive.TGCPlus_User                
where entitled_dt is null       
and email not like '%+%'                
and joined between dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) and DataWarehouse.Staging.GetSunday(getdate())                
and TGCPluscampaign in ( Select adcode from DataWarehouse.Mapping.vwAdcodesAll  where MD_Audience like '%Subscription%' and (MD_Channel ='Television' or MD_CampaignName like '%DRTV%')  )                
group by convert(varchar,joined,112),replace(CONVERT(VARCHAR(5), Joined, 108),':','')                
                
union ALL                
--Leads  DRTV              
select 'TELE' as Telemarketer,                
      4732826877 as TollFreeNum,                
      convert(varchar,joined,112) as Date,                
      replace(CONVERT(VARCHAR(5), Joined, 108),':','') AS MilitaryTime,                
      --joined,                
      'LEAD' as Response,                
      RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6) TotalCounts,                
      CONVERT(char(6),'      ') as DNISCode,                
      CONVERT(char(5),'     ') as ZIP,                
      CONVERT(char(3),'999') as AreaCode,                
      'TELE' + '4732826877' + convert(varchar,joined,112)+replace(CONVERT(VARCHAR(5), Joined, 108),':','')+'LEAD'+RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6)+                
      CONVERT(char(6),'      ')+CONVERT(char(5),'     ')+CONVERT(char(3),'999') as Output                
from DataWarehouse.Archive.TGCPlus_User                
where entitled_dt between dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) and DataWarehouse.Staging.GetSunday(getdate())     
and email not like '%+%'                  
and TGCPluscampaign in ( Select adcode from DataWarehouse.Mapping.vwAdcodesAll  where MD_Audience like '%Subscription%' and (MD_Channel ='Television' or MD_CampaignName like '%DRTV%')  )                
group by convert(varchar,joined,112),replace(CONVERT(VARCHAR(5), Joined, 108),':','')                 
                
union ALL                
--Vistit DRTV               
select 'TELE' as Telemarketer,                
      4732826877 as TollFreeNum,                
      convert(varchar,cast([Date] as Date),112) as [Date],                
      case when len([Hour])= 1 then '0' + [Hour] else [Hour] end + case when len([Minute])=1 then '0' + [Minute] else [Minute] end AS MilitaryTime,                
      'VIST' as Response,                
      RIGHT('000000'+ISNULL(convert(varchar,sum([Sessions])),''),6) TotalCounts,                
      CONVERT(char(6),'      ') as DNISCode,                
      CONVERT(char(5),'     ') as ZIP,                
      CONVERT(char(3),'999') as AreaCode,                
      cast('TELE' + '4732826877' + convert(varchar,cast([Date] as Date),112) + case when len([Hour])=1 then '0' + [Hour] else [Hour] end          
      + case when len([Minute])=1 then '0' + [Minute] else [Minute] end +'VIST'+RIGHT('000000'+ISNULL(convert(varchar,sum([Sessions])),''),6)+                
      CONVERT(char(6),'      ')+CONVERT(char(5),'     ')+CONVERT(char(3),'999') as varchar(50))as Output                
from  Marketing.TGCPLus_GA_Visits a               
 --(select Campaign, cast ([date] as date)[date],[Hour],[minute] ,cast(Sessions as int)Sessions                
 --,Case when isnull(campaign,'(not set)') = '(not set)' then 120091 /* Default for nulls*/                
 --   when patindex('%[a-z]%', campaign)> 0 then 120091 /* Default*/                
 --   else campaign end as TGCPluscampaign                 
 --from Staging.GA_ssis_visitor                
 --)a             
 where [DATE] between dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) and DataWarehouse.Staging.GetSunday(getdate())                
 and Campaign in ( Select adcode from DataWarehouse.Mapping.vwAdcodesAll  where MD_Audience like '%Subscription%' and (MD_Channel ='Television' or MD_CampaignName like '%DRTV%')  )                
 group by [DATE],[Hour],[minute]                
                
Union all      
      
--Registrations  Paid Search              
select 'TELE' as Telemarketer,                
      4732826877 as TollFreeNum,                
      convert(varchar,joined,112) as Date,                
      replace(CONVERT(VARCHAR(5), Joined, 108),':','') AS MilitaryTime,                
      --joined,                
      'SREG' as Response,                
      RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6) TotalCounts,                
      CONVERT(char(6),'      ') as DNISCode,                
      CONVERT(char(5),'     ') as ZIP,                
      CONVERT(char(3),'999') as AreaCode,                
      'TELE' + '4732826877' + convert(varchar,joined,112)+replace(CONVERT(VARCHAR(5), Joined, 108),':','')+'SREG'+RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6)+                
      CONVERT(char(6),'      ')+CONVERT(char(5),'     ')+CONVERT(char(3),'999') as Output                
from DataWarehouse.Archive.TGCPlus_User                
where entitled_dt is null         
and email not like '%+%'              
and joined between dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) and DataWarehouse.Staging.GetSunday(getdate())                
and TGCPluscampaign in ( Select adcode from DataWarehouse.Mapping.vwAdcodesAll  where MD_Audience like '%Subscription%' and  MD_Channel ='paid search'  )                
group by convert(varchar,joined,112),replace(CONVERT(VARCHAR(5), Joined, 108),':','')                
                
union ALL                
--Leads Paid Search           
select 'TELE' as Telemarketer,                
      4732826877 as TollFreeNum,                
      convert(varchar,joined,112) as Date,                
      replace(CONVERT(VARCHAR(5), Joined, 108),':','') AS MilitaryTime,                
      --joined,                
      'SLED' as Response,                
      RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6) TotalCounts,                
      CONVERT(char(6),'      ') as DNISCode,                
      CONVERT(char(5),'     ') as ZIP,                
      CONVERT(char(3),'999') as AreaCode,                
      'TELE' + '4732826877' + convert(varchar,joined,112)+replace(CONVERT(VARCHAR(5), Joined, 108),':','')+'SLED'+RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6)+                
      CONVERT(char(6),'      ')+CONVERT(char(5),'     ')+CONVERT(char(3),'999') as Output                
from DataWarehouse.Archive.TGCPlus_User                
where entitled_dt between dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) and DataWarehouse.Staging.GetSunday(getdate())     
and email not like '%+%'                  
and TGCPluscampaign in ( Select adcode from DataWarehouse.Mapping.vwAdcodesAll  where MD_Audience like '%Subscription%' and  MD_Channel ='paid search'   )                
group by convert(varchar,joined,112),replace(CONVERT(VARCHAR(5), Joined, 108),':','')                 
                
union ALL                
--Vistit Paid Search          
select 'TELE' as Telemarketer,                
      4732826877 as TollFreeNum,                
      convert(varchar,cast([Date] as Date),112) as [Date],                
      case when len([Hour])= 1 then '0' + [Hour] else [Hour] end + case when len([Minute])=1 then '0' + [Minute] else [Minute] end AS MilitaryTime,                
      'SVST' as Response,                
      RIGHT('000000'+ISNULL(convert(varchar,sum([Sessions])),''),6) TotalCounts,                
      CONVERT(char(6),'      ') as DNISCode,                
      CONVERT(char(5),'     ') as ZIP,                
      CONVERT(char(3),'999') as AreaCode,                
      cast('TELE' + '4732826877' + convert(varchar,cast([Date] as Date),112) + case when len([Hour])=1 then '0' + [Hour] else [Hour] end           
      + case when len([Minute])=1 then '0' + [Minute] else [Minute] end +'SVST'+RIGHT('000000'+ISNULL(convert(varchar,sum([Sessions])),''),6)+                
      CONVERT(char(6),'      ')+CONVERT(char(5),'     ')+CONVERT(char(3),'999') as varchar(50))as Output                
from Marketing.TGCPLus_GA_Visits a                
 --(select Campaign, cast ([date] as date)[date],[Hour],[minute] ,cast(Sessions as int)Sessions                
 --,Case when isnull(campaign,'(not set)') = '(not set)' then 120091 /* Default for nulls*/                
 --   when patindex('%[a-z]%', campaign)> 0 then 120091 /* Default*/                
 --   else campaign end as TGCPluscampaign                 
 --from Staging.GA_ssis_visitor                
 --)a             
 where [DATE] between dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) and DataWarehouse.Staging.GetSunday(getdate())                
 and Campaign in ( Select adcode from DataWarehouse.Mapping.vwAdcodesAll  where MD_Audience like '%Subscription%' and  MD_Channel ='paid search'   )                
 group by [DATE],[Hour],[minute]               
       
 Union all      
       
 --Registrations Web Deafults              
select 'TELE' as Telemarketer,                
      4732826877 as TollFreeNum,                
      convert(varchar,joined,112) as Date,                
      replace(CONVERT(VARCHAR(5), Joined, 108),':','') AS MilitaryTime,                
      --joined,                
      'DREG' as Response,                
      RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6) TotalCounts,                
      CONVERT(char(6),'      ') as DNISCode,                
      CONVERT(char(5),'     ') as ZIP,                
      CONVERT(char(3),'999') as AreaCode,                
      'TELE' + '4732826877' + convert(varchar,joined,112)+replace(CONVERT(VARCHAR(5), Joined, 108),':','')+'DREG'+RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6)+                
      CONVERT(char(6),'      ')+CONVERT(char(5),'     ')+CONVERT(char(3),'999') as Output                
from DataWarehouse.Archive.TGCPlus_User                
where entitled_dt is null        
and email not like '%+%'               
and joined between dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) and DataWarehouse.Staging.GetSunday(getdate())                
and TGCPluscampaign in ( Select adcode from DataWarehouse.Mapping.vwAdcodesAll  where MD_Audience like '%Subscription%' and MD_Channel ='Prospect web'   )                
group by convert(varchar,joined,112),replace(CONVERT(VARCHAR(5), Joined, 108),':','')                
                
union ALL                
--Leads Web Deafults           
select 'TELE' as Telemarketer,                
      4732826877 as TollFreeNum,                
      convert(varchar,joined,112) as Date,                
      replace(CONVERT(VARCHAR(5), Joined, 108),':','') AS MilitaryTime,                
      --joined,                
 'DLED' as Response,                
      RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6) TotalCounts,                
      CONVERT(char(6),'      ') as DNISCode,                
      CONVERT(char(5),'     ') as ZIP,                
      CONVERT(char(3),'999') as AreaCode,                
      'TELE' + '4732826877' + convert(varchar,joined,112)+replace(CONVERT(VARCHAR(5), Joined, 108),':','')+'DLED'+RIGHT('000000'+ISNULL(convert(varchar,COUNT(*)),''),6)+                
      CONVERT(char(6),'      ')+CONVERT(char(5),'     ')+CONVERT(char(3),'999') as Output                
from DataWarehouse.Archive.TGCPlus_User                
where entitled_dt between dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) and DataWarehouse.Staging.GetSunday(getdate())          
and email not like '%+%'             
and TGCPluscampaign in ( Select adcode from DataWarehouse.Mapping.vwAdcodesAll  where MD_Audience like '%Subscription%' and MD_Channel ='Prospect web'   )                
group by convert(varchar,joined,112),replace(CONVERT(VARCHAR(5), Joined, 108),':','')                 
                
union ALL                
--Vistit Web Deafults               
select 'TELE' as Telemarketer,                
      4732826877 as TollFreeNum,                
      convert(varchar,cast([Date] as Date),112) as [Date],                
      case when len([Hour])= 1 then '0' + [Hour] else [Hour] end + case when len([Minute])=1 then '0' + [Minute] else [Minute] end AS MilitaryTime,                
      'DVST' as Response,                
      RIGHT('000000'+ISNULL(convert(varchar,sum([Sessions])),''),6) TotalCounts,                
      CONVERT(char(6),'      ') as DNISCode,                
      CONVERT(char(5),'     ') as ZIP,                
      CONVERT(char(3),'999') as AreaCode,                
      cast('TELE' + '4732826877' + convert(varchar,cast([Date] as Date),112) + case when len([Hour])=1 then '0' + [Hour] else [Hour] end           
      + case when len([Minute])=1 then '0' + [Minute] else [Minute] end +'DVST'+RIGHT('000000'+ISNULL(convert(varchar,sum([Sessions])),''),6)+                
      CONVERT(char(6),'      ')+CONVERT(char(5),'     ')+CONVERT(char(3),'999') as varchar(50))as Output                
from Marketing.TGCPLus_GA_Visits a                
 --(select Campaign, cast ([date] as date)[date],[Hour],[minute] ,cast(Sessions as int)Sessions                
 --,Case when isnull(campaign,'(not set)') = '(not set)' then 120091 /* Default for nulls*/                
 --   when patindex('%[a-z]%', campaign)> 0 then 120091 /* Default*/                
 --   else campaign end as TGCPluscampaign                 
 --from Staging.GA_ssis_visitor                
 --)a             
 where [DATE] between dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) and DataWarehouse.Staging.GetSunday(getdate())                
 and Campaign in ( Select adcode from DataWarehouse.Mapping.vwAdcodesAll  where MD_Audience like '%Subscription%' and MD_Channel ='Prospect web'   )                
 group by [DATE],[Hour],[minute]                          

GO
