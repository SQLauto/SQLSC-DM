SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*- Proc Name:  Datawarehse.staging.[CreateWDMonthlyFile]*/      
/*- Purpose: This creates monthly file for WebDecisions */      
/*- Input Parameters: */      
/*- Updates:*/      
/*- Name  Date  Comments*/      
/*- Preethi Ramanujam  6/5/2014 New*/    
/* Adding TGCplus Changes ,Source and Fullnames 2/25/2016*/    
/*-*/      
      
CREATE PROC [Staging].[Monthly_CustFile_ForWD]      
AS      
begin      

/* Update CustomerListExchangeSubjectCats */

if object_id('mapping.CustomerListExchangeSubjectCats')is not null
Drop table DataWarehouse.mapping.CustomerListExchangeSubjectCats
--Truncate table DataWarehouse.mapping.CustomerListExchangeSubjectCats

--Insert  Into DataWarehouse.mapping.CustomerListExchangeSubjectCats
Select Customerid, max( case when CCP.courseid in (7931,7901,7912,7923)then 1 else 0 end )  as FlagPhotography
,max( case when CCP.courseid in (7931,7901,7912,7923)then DateOrdered else null end )  as FlagPhotography_LOD
, max( case when CCP.courseid in (9292,9231,9253,9211,9222,9271,9284) then 1 else 0 end )  as FlagCooking
, max( case when CCP.courseid in (9292,9231,9253,9211,9222,9271,9284) then DateOrdered else null end )  as FlagCooking_LOD
, max( case when CCP.courseid in (1908,1933,9263,9303)then 1 else 0 end )  as FlagSpirituality
, max( case when CCP.courseid in (1908,1933,9263,9303)then DateOrdered else null end )  as FlagSpirituality_LOD
, max( case when CCP.courseid in (1852,1884,1810,146,158,180, 190 ,1830,1823,1802,1841,1846,1816,1872,1893,1898)then 1 else 0 end )  as FlagAstronomy
, max( case when CCP.courseid in (1852,1884,1810,146,158,180, 190 ,1830,1823,1802,1841,1846,1816,1872,1893,1898)then DateOrdered else null end )  as FlagAstronomy_LOD
, max( case when CCP.courseid in (6433,6206,6240,6252,6299,6481,6537,6577,6593,6627,6633,6672,6101,6450,6260,6640,611,615,643,647,656,657,690,6610,7842,6410,6522,6271)then 1 else 0 end )  as Flagchristianity
, max( case when CCP.courseid in (6433,6206,6240,6252,6299,6481,6537,6577,6593,6627,6633,6672,6101,6450,6260,6640,611,615,643,647,656,657,690,6610,7842,6410,6522,6271)then DateOrdered else null end )  as Flagchristianity_LOD
, max( case when C.SubjectCategory2 = 'SCI' then DateOrdered else null end )  as SCI_LOD
, max( case when C.SubjectCategory2 = 'MTH' then DateOrdered else null end )  as MTH_LOD
, max( case when C.SubjectCategory2 = 'MSC' then DateOrdered else null end )  as MSC_LOD
, max( case when C.SubjectCategory2 = 'VA' then DateOrdered else null end )  as VA_LOD
, max( case when C.SubjectCategory2 = 'RL' then DateOrdered else null end )  as RL_LOD
, max( case when C.SubjectCategory2 = 'AH' then DateOrdered else null end )  as AH_LOD
, max( case when C.SubjectCategory2 = 'MH' then DateOrdered else null end )  as MH_LOD
, max( case when C.SubjectCategory2 = 'EC' then DateOrdered else null end )  as EC_LOD
, max( case when C.SubjectCategory2 = 'LIT' then DateOrdered else null end )  as LIT_LOD
, max( case when C.SubjectCategory2 = 'FW' then DateOrdered else null end )  as BL_LOD
, max( case when C.SubjectCategory2 = 'PR' then DateOrdered else null end )  as PR_LOD
, max( case when C.SubjectCategory2 = 'HS' then DateOrdered else null end )  as HS_LOD
, max( case when C.SubjectCategory2 = 'PH' then DateOrdered else null end )  as PH_LOD
,getdate() as LastUpdatedate
into DataWarehouse.mapping.CustomerListExchangeSubjectCats
 from DataWarehouse.Marketing.CompleteCoursePurchase ccp
 JOIN DataWarehouse.Mapping.DmCourse C
 on CCP.CourseID = C.CourseID
 group by Customerid			



      
---- Create Initial Marketing Channel information      
 if object_id('Staging.Temp_WD_MonthlyIntlOrder1') is not null drop table Staging.Temp_WD_MonthlyIntlOrder1      
       
 select a.CustomerID, a.IntlPurchaseAdCode, b.AdcodeName, isnull(b.MD_Channel,'Unknown') as IntlOrderChannel      
 into Staging.Temp_WD_MonthlyIntlOrder1      
 from Marketing.DMCustomerStatic a      
 left join Mapping.vwAdcodesAll b on a.IntlPurchaseAdCode = b.AdCode      
      
---- First pull Customer Level Data      
      
 if object_id('Staging.Temp_WD_MonthlyFile') is not null drop table Staging.Temp_WD_MonthlyFile      
      
 select a.CustomerID,       
  isnull(a.Prefix,'') Prefix,       
  a.FirstName,       
  isnull(a.MiddleName,'') MiddleName,       
  a.LastName,       
  isnull(a.Suffix,'') Suffix,      
  isnull(a.Address1,'') Address1,       
  isnull(a.Address2,'') Address2,       
  isnull(a.Address3,'') Address3,       
  isnull(a.City,'') City,       
  isnull(a.State,'') State,       
  isnull(a.PostalCode,'') PostalCode,      
  isnull(a.Gender,'') Gender,      
  a.Frequency,      
  case when a.FlagOKtoshare = 1 then 'Y'      
   else 'N'      
  end as FlagRntlExchng,      
  ISNULL(e.MatchResult, 1) as FlagNeedDemoAppnd,      
  isnull(c.LTDAvgOrd,'') LTDAvgOrd,      
  isnull(d.LastOrderDate,'') LastOrderDate,      
  convert(int, a.SCI) SCI, convert(int, a.MTH) MTH, convert(int, a.MSC) MSC, convert(int, a.VA) VA,      
  convert(int, a.RL) RL, convert(int, a.AH) AH,       
  convert(int, a.MH) MH, convert(int, a.EC) EC,       
  convert(int, a.LIT) LIT, convert(int, a.FW) as BL,      
  convert(int, a.PR) PR, convert(int, a.HS) HS, convert(int, a.PH) PH,      
  isnull(f.IntlOrderChannel,'Unknown') as IntlOrderChannel,      
  cast(GetDate() as Date) AsOfDate,  
  cast('TGC' as varchar(50))   as Source,  
  cast( FirstName + ' ' + LastName as varchar(255)) as FullName,
    Isnull(L.FlagPhotography,0) as FlagPhotography,
	Isnull(L.FlagCooking,0) as FlagCooking,
	Isnull(L.FlagSpirituality,0) as FlagSpirituality,
	Isnull(L.FlagAstronomy,0) as FlagAstronomy,
	Isnull(L.Flagchristianity,0) as Flagchristianity
	,SCI_LOD,MTH_LOD,MSC_LOD,VA_LOD,RL_LOD,AH_LOD,MH_LOD,EC_LOD,LIT_LOD,BL_LOD,PR_LOD,HS_LOD,PH_LOD,FlagPhotography_LOD,FlagCooking_LOD, FlagSpirituality_LOD,FlagAstronomy_LOD,Flagchristianity_LOD
 into Staging.Temp_WD_MonthlyFile      
 from Marketing.CampaignCustomerSignature a       
  left join Marketing.CustomerDynamicCourseRank c on a.CustomerID = c.CustomerID      
  left join [Staging].[vwCustomerLastOrderDate] d on a.CustomerID = d.CustomerID      
  left join Mapping.CustomerOverlay_WD e on a.CustomerID = e.CustomerID      
  left join Staging.Temp_WD_MonthlyIntlOrder1 f on a.CustomerID = f.CustomerID      
  left join Mapping.CustomerListExchangeSubjectCats L on L.customerid = a.CustomerID
 where a.CountryCode in ('US')       
      
  Union    
      
  select cast(1000000000 + b.id as nvarchar(20))as CustomerID,     
      cast(''  as varchar(50)) as prefix,    
      cast( a.userfirstname as varchar(50)) as FirstName,    
      cast('' as nvarchar(25))as MiddleName,    
      cast( a.Userlastname as varchar(50))as LastName,    
      cast('' as varchar(50)) as Suffix,    
        cast( a.line1 as nvarchar(120))as Address1,    
        cast( a.line2 as nvarchar(10))as Address2,    
        cast( a.line3 as nvarchar(120))as Address3,    
        cast( a.city as nvarchar(60)) as city,    
        cast( a.region as varchar(40))as state,    
        cast(a.PostalCode as varchar(40))PostalCode,    
        --CAST('U' as CHAR (2)) as Gender,    
        ISNULL(Left(e.Gender,1),'') as Gender, 
        CAST(0 as varchar(5)) as Frequency,         
      'N' as FlagRntlExchng,    
	  ISNULL(e.MatchResult, 1) as FlagNeedDemoAppnd,      
      cast(0 as money) as LTDAvgOrd,    
      isnull(b.entitled_dt,'2015-12-01') as LastOrderDate,    
      0 as SCI,    
      0 as MTH,    
      0 as MSC,    
      0 as VA,    
      0 as RL,    
      0 as AH,    
      0 as MH,    
	  0 as EC,    
      0 as LIT,    
      0 as BL,    
      0 as PR,    
      0 as HS,    
      0 as PH,    
        cast('TGCPlus' as varchar(50)) as IntlOrderChannel,    
        cast(DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) as DATE) as AsOfDate,   
        cast('TGCPlus' as varchar(50))   as Source,  
  a.FullName,
    0 as FlagPhotography,
	0 as FlagCooking,
	0 as FlagSpirituality,
	0 as FlagAstronomy,
	0 as Flagchristianity ,
	 null as SCI_LOD,null as MTH_LOD,null as MSC_LOD,null as VA_LOD,null as RL_LOD,null as AH_LOD,null as MH_LOD,null as EC_LOD,null as LIT_LOD,null as BL_LOD,
	 null as PR_LOD,null as HS_LOD,null as PH_LOD,null as  FlagPhotography_LOD,null as FlagCooking_LOD,null as  FlagSpirituality_LOD,null as FlagAstronomy_LOD,null as Flagchristianity_LOD
   
   
from DataWarehouse.Archive.TGCPlus_billingAddress a join    
      DataWarehouse.Archive.TGCPlus_User b on a.userid = b.uuid    
  left join Mapping.TGCPlus_CustomerOverlay e on b.ID = e.CustomerID      
      
where useremail not like '%+%'    
and isnull(a.line1,'') <> ''    
and useremail not like '%teachco%'    
and line1 not like '4840 Westfields%'    
and (country in ('US','United States Virgin Islands','United States','')    or country is null )

  Union    
      
  select cast(2000000000 + a.FBA_AddressID as nvarchar(20))as CustomerID,     
      cast(''  as varchar(50)) as prefix,    
      cast( '' as varchar(50)) as FirstName,    
      cast('' as nvarchar(25))as MiddleName,    
      cast( '' as varchar(50))as LastName,    
      cast('' as varchar(50)) as Suffix,    
        cast( a.ship_address_1 as nvarchar(120))as Address1,    
        cast( a.ship_address_2 as nvarchar(10))as Address2,    
        cast( a.ship_address_3 as nvarchar(120))as Address3,    
        cast( a.ship_city as nvarchar(60)) as city,    
        cast( a.ship_state as varchar(40))as state,    
        cast(a.ship_postal_code as varchar(40))PostalCode,    
        CAST('U' as CHAR (2)) as Gender,    
        CAST(0 as varchar(5)) as Frequency,         
      'N' as FlagRntlExchng,    
	  1 as FlagNeedDemoAppnd,      
      cast(0 as money) as LTDAvgOrd,    
      isnull(a.Initialpurchase_date,cast(getdate() as date)) as LastOrderDate,    
      0 as SCI,    
      0 as MTH,    
      0 as MSC,    
      0 as VA,    
      0 as RL,    
      0 as AH,    
      0 as MH,    
	  0 as EC,    
      0 as LIT,    
      0 as BL,    
      0 as PR,    
      0 as HS,    
      0 as PH,    
        cast('TGCFBA' as varchar(50)) as IntlOrderChannel,    
        cast(DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) as DATE) as AsOfDate,   
        cast('TGCFBA' as varchar(50))   as Source,  
	a.recipient_name,
    0 as FlagPhotography,
	0 as FlagCooking,
	0 as FlagSpirituality,
	0 as FlagAstronomy,  
    0 as Flagchristianity ,
	 null as SCI_LOD,null as MTH_LOD,null as MSC_LOD,null as VA_LOD,null as RL_LOD,null as AH_LOD,null as MH_LOD,null as EC_LOD,null as LIT_LOD,null as BL_LOD,
	 null as PR_LOD,null as HS_LOD,null as PH_LOD,null as  FlagPhotography_LOD,null as FlagCooking_LOD,null as  FlagSpirituality_LOD,null as FlagAstronomy_LOD,null as Flagchristianity_LOD 
from DataWarehouse.Mapping.FBA_Customer_Address a      
where isnull(a.ship_address_1,'') <> ''    
and ship_address_1 not like '4840 Westfields%'    
and ship_country in ('US','United States Virgin Islands','United States','')      
      
 /*Yearly full refresh*/

 if datepart(m,getdate()) = 2
 begin

 update Staging.Temp_WD_MonthlyFile
 set FlagNeedDemoAppnd = 1

 End
 
 -- Create final files for WebDecisions      
 declare @WDTable varchar(100),      
  @Qry varchar(8000),      
  @WDTable2 varchar(100)      
        
 select @WDTable = 'rfm..WD_MonthlyCustomerFile_' + CONVERT(varchar,getdate(),112)      
      
 select @WDTable2 = 'WD_MonthlyCustomerFile_' + CONVERT(varchar,getdate(),112)      
      
 IF EXISTS(SELECT 1 FROM rfm.sys.tables WHERE name = @WDTable2)       
  begin      
   set @Qry = 'Drop table ' + @WDTable      
   print @Qry      
   exec (@Qry)          
  end      
           
 set @Qry = 'select *      
    into ' + @WDTable +       
    ' from Staging.Temp_WD_MonthlyFile'      
          
 print @Qry      
 exec (@Qry)        
       
       
 exec staging.ExportTableToPipeText rfm, dbo, @WDTable2, '\\File1\Groups\Marketing\WebDecisions\HouseFileInformationToWD\MonthlyHouseFiles'      
      
 drop table Staging.Temp_WD_MonthlyFile      
      
end      





GO
