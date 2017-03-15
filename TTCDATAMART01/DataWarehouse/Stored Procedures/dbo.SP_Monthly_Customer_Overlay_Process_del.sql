SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_Monthly_Customer_Overlay_Process_del]  
as  
Begin  
  
Declare @date datetime  
  
Set @date = cast(CONVERT(date, getdate())as Datetime)  
  
  
/*Droping staging table and adding mapping info*/  
drop table datawarehouse.Mapping.CustomerOverlay_WD2  
    
select AcctNo as CustomerID,  
  convert(int,MatchResult) as MatchResult,  
  case when MATCHRESULT = 0 then '0: DoesNotNeedOverlay'  
  when MATCHRESULT = 1 then '1: NeedOverlay'  
  end as MatchResultDesc,  
  convert(varchar(1),Income) Income,  
  case when income = '1' then '1: $0-$14,999'  
  when income = '2' then '2: $15,000 - $19,999'  
  when income = '3' then '3: $20,000 - $29,999'  
  when income = '4' then '4: $30,000 - $39,999'  
  when income = '5' then '5: $40,000 - $49,999'  
  when income = '6' then '6: $50,000 - $74,999'  
  when income = '7' then '7: $75,000 - $99,999'  
  when income = '8' then '8: $100,000 - $124,999'  
  when income = '9' then '9: $125,000 - $149,999'  
  when income = 'A' then '10: $150,000 - $174,999'  
  when income = 'B' then '11: $175,000 - $199,999'  
  when income = 'C' then '12: $200,000 - $249,000'  
  when income = 'D' then '13: $250,000+'  
  else '14: Unknown'  
  end as IncomeDescription,  
  CONVERT(int,HHED) as EducationID,  
  case when hhed = 0 then '6: Unknown'  
  when hhed = 1 then '1: Some High School or Less'  
  when hhed = 2 then '2: High School'  
  when hhed = 3 then '3: Some College'  
  when hhed = 4 then '4: College'  
  when hhed = 5 then '5: Graduate School'  
  else '6: Unknown'  
  end as Education,  
  --BDPRSNWD Birth Date                                                   Format: CCYYMMDD  
  BDPRSNWD as BirthDate_CCYYMM,   
  case when len(BDPRSNWD) > 0  then   
  convert(int,LEFT(BDPRSNWD,4))  
  else null end as BirthYear,  
  case when len(BDPRSNWD) > 0 then   
  convert(int,substring(BDPRSNWD,5,2))  
  else null  
  end as BirthMonth,  
  case when LEFT(BDPRSNWD,4) > 0 then  
  convert(datetime,convert(varchar,case when len(BDPRSNWD) > 0   
  then substring(BDPRSNWD,5,2)  
  else '1'  
  end + '/' + RIGHT(bdprsnwd,2) + '/' + LEFT(BDPRSNWD,4),101))   
  else null  
  end DateOfBirth,  
  Gender = case when epGender = 'M' then 'Male'  
  when epgender = 'F' then 'Female'  
  else 'Unknown'  
  end,  
  PresenceOfChildren = case when PRSNCCHLD = 0 then '2: No Children Present'  
  when PRSNCCHLD = 1 then '1: Yes Children Present'  
  else '3: Unknown'  
  end,  
  NetWorth = case when NETWORTH = 0 then '1: Less Than $25,000'  
  when NETWORTH = 1 then '2: $25,000 - $49,999'  
  when NETWORTH = 2 then '3: $50,000 - $74,999'  
  when NETWORTH = 3 then '4: $75,000 - $99,999'  
  when NETWORTH = 4 then '5: $100,000 - $149,999'  
  when NETWORTH = 5 then '6: $150,000 - $249,999'  
  when NETWORTH = 6 then '7: $250,000 - $499,999'  
  when NETWORTH = 7 then '8: $500,000 - $749,999'  
  when NETWORTH = 8 then '9: $750,000 - $999,999'  
  when NETWORTH = 9 then '10: $100,000,000+'  
  else '11: Uknown'  
  end,  
  MailOrderBuyer = case when MOBUYER = 'Y' then 'Y'  
  else 'N'  
  end,  
  RCM_Score,  
  @date as DateFromWD,  
  GETDATE() as DateUpdated,  
  null as UpdateFromWD,  
  WDScore,  
  WDScoreRaw as WDRAwScore  
 into datawarehouse.mapping.CustomerOverlay_WD2       
 from datawarehouse..TTC_Net_Name_pipe  
  
 /* Insert new records*/   
 insert into DataWarehouse.Mapping.CustomerOverlay_WD  
 select a.*  
 from DataWarehouse.Mapping.CustomerOverlay_WD2 a left join  
 DataWarehouse.Mapping.CustomerOverlay_WD b on a.CustomerID = b.CustomerID  
 where b.CustomerID is null and a.CustomerID <1000000000
 
 
 
/* Insert new records TGC PLus*/   
 insert into DataWarehouse.Mapping.TGCPlus_CustomerOverlay  
 select a.*  
 from DataWarehouse.Mapping.CustomerOverlay_WD2 a left join  
 DataWarehouse.Mapping.TGCPlus_CustomerOverlay b on a.CustomerID = b.CustomerID  
 where b.CustomerID is null and a.CustomerID > 1000000000 
   
 /* Update standard Score fields */  
 update a  
 set a.rcm_score = b.rcm_score,  
 a.WdScore = b.wDScore,  
 a.WdRawScore = b.wdrawscore  
 from DataWarehouse.Mapping.CustomerOverlay_WD a join  
 DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID = b.CustomerID  



 /* Update standard Score fields TGC plus */  
 update a  
 set a.rcm_score = b.rcm_score,  
 a.WdScore = b.wDScore,  
 a.WdRawScore = b.wdrawscore  
 from DataWarehouse.Mapping.TGCPlus_CustomerOverlay a join  
 DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID = b.CustomerID    
  
  --select *  
  --from DataWarehouse.Mapping.CustomerOverlay_WD a join  
  --DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID = b.CustomerID  
  --where a.MatchResult = 1   
  --and b.MatchResult = 0  
  
/* update previously not updated records*/  
 update a  
 set a.MatchResult = b.MatchResult,  
  a.MatchResultDesc = b.MatchResultDesc,  
  a.Income = b.Income,  
  a.IncomeDescription = b.IncomeDescription,  
  a.EducationID = b.EducationID,  
  a.Education = b.Education,  
  a.BirthDate_CCYYMM = b.BirthDate_CCYYMM,  
  a.BirthYear = b.BirthYear,  
  a.BirthMonth = b.BirthMonth,  
  a.DateOfBirth = b.DateOfBirth,  
  a.Gender = b.Gender,  
  a.PresenceOfChildren = b.PresenceOfChildren,  
  a.NetWorth = b.NetWorth,  
  a.MailOrderBuyer  = b.MailOrderBuyer,  
  a.rcm_Score = b.rcm_score,  
  a.wdscore = b.wdscore,  
  a.wdrawscore = b.wdrawscore,  
  a.updatefromWD = @date  
 -- select *   
 from DataWarehouse.Mapping.CustomerOverlay_WD a join  
  DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID = b.CustomerID  
 where a.MatchResult = 1   
 and b.MatchResult = 0  


/* update previously not updated records TGC Plus */  
 update a  
 set a.MatchResult = b.MatchResult,  
  a.MatchResultDesc = b.MatchResultDesc,  
  a.Income = b.Income,  
  a.IncomeDescription = b.IncomeDescription,  
  a.EducationID = b.EducationID,  
  a.Education = b.Education,  
  a.BirthDate_CCYYMM = b.BirthDate_CCYYMM,  
  a.BirthYear = b.BirthYear,  
  a.BirthMonth = b.BirthMonth,  
  a.DateOfBirth = b.DateOfBirth,  
  a.Gender = b.Gender,  
  a.PresenceOfChildren = b.PresenceOfChildren,  
  a.NetWorth = b.NetWorth,  
  a.MailOrderBuyer  = b.MailOrderBuyer,  
  a.rcm_Score = b.rcm_score,  
  a.wdscore = b.wdscore,  
  a.wdrawscore = b.wdrawscore,  
  a.updatefromWD = @date  
 -- select *   
 from DataWarehouse.Mapping.TGCPlus_CustomerOverlay a join  
  DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID = b.CustomerID  
 where a.MatchResult = 1   
 and b.MatchResult = 0  

  
  
END

 
 
GO
