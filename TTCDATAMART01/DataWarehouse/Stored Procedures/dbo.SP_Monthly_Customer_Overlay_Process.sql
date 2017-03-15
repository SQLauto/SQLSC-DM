SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_Monthly_Customer_Overlay_Process]    
as    
Begin    
    
Declare @date datetime    
    
Set @date = cast(CONVERT(date, getdate())as Datetime)    
 select   @date 
    
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
  --Gender = case when epGender = 1 then 'Male'    
  --when epgender = 2 then 'Female'    
  --else 'Unknown'    
  --end,    
  Gender = case when epGender = 'M' or epGender = '1' then 'Male'    
  when epgender = 'F' or  epgender = '2' then 'Female'    
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
  WDScoreRaw as WDRAwScore,
  FName as FirstName,
  LName as LastName,
  FullName,
  ADD1,
  ADD2,
  ADD3,
  CITY,
  STATE,
  ZIP
      
 into datawarehouse.mapping.CustomerOverlay_WD2         
 from datawarehouse..TTC_Net_Name_pipe    


 /*
/* Load Dropped TGCPlus Customerid from mapping.TGCPlus_Merge_Dupes based on TGC customerid */
Insert into datawarehouse.mapping.CustomerOverlay_WD2
select distinct FNL.* from 
(
select TGCPlusCustomerid + 1000000000 as CustomerID,WD.MatchResult,WD.MatchResultDesc,WD.Income,WD.IncomeDescription,WD.EducationID,WD.Education,WD.BirthDate_CCYYMM,WD.BirthYear,
WD.BirthMonth,WD.DateOfBirth,WD.Gender,WD.PresenceOfChildren,WD.NetWorth,WD.MailOrderBuyer,WD.RCM_Score,WD.DateFromWD,WD.DateUpdated,
WD.UpdateFromWD,WD.WDScore,WD.WDRAwScore,WD.FirstName,WD.LastName,WD.FullName,WD.ADD1,WD.ADD2,WD.ADD3,WD.CITY,WD.STATE,WD.ZIP
from datawarehouse.mapping.CustomerOverlay_WD2    WD
join Datawarehouse.mapping.TGCPlus_Merge_Dupes D
on WD.CustomerID = D.acctno
)FNL
Left join datawarehouse.mapping.CustomerOverlay_WD2 WD
on WD.CustomerID = Fnl.CustomerID
where  WD.CustomerID is null

/* Load Dropped FBA Customerid from mapping.FBA_Merge_Dupes based on TGC customerid */
Insert into datawarehouse.mapping.CustomerOverlay_WD2
select distinct FNL.* from 
(
select FBACustomerid + 2000000000 as CustomerID,WD.MatchResult,WD.MatchResultDesc,WD.Income,WD.IncomeDescription,WD.EducationID,WD.Education,WD.BirthDate_CCYYMM,WD.BirthYear,
WD.BirthMonth,WD.DateOfBirth,WD.Gender,WD.PresenceOfChildren,WD.NetWorth,WD.MailOrderBuyer,WD.RCM_Score,WD.DateFromWD,WD.DateUpdated,
WD.UpdateFromWD,WD.WDScore,WD.WDRAwScore,WD.FirstName,WD.LastName,WD.FullName,WD.ADD1,WD.ADD2,WD.ADD3,WD.CITY,WD.STATE,WD.ZIP
from datawarehouse.mapping.CustomerOverlay_WD2    WD
join Datawarehouse.mapping.FBA_Merge_Dupes D
on WD.CustomerID = D.acctno
)FNL
Left join datawarehouse.mapping.CustomerOverlay_WD2 WD
on WD.CustomerID = Fnl.CustomerID
where  WD.CustomerID is null

/* Load Dropped FBA Customerid from mapping.FBA_Merge_Dupes based on TGCPlus customerid */
Insert into datawarehouse.mapping.CustomerOverlay_WD2
select distinct FNL.* from 
(
select FBACustomerid + 2000000000 as CustomerID,WD.MatchResult,WD.MatchResultDesc,WD.Income,WD.IncomeDescription,WD.EducationID,WD.Education,WD.BirthDate_CCYYMM,WD.BirthYear,
WD.BirthMonth,WD.DateOfBirth,WD.Gender,WD.PresenceOfChildren,WD.NetWorth,WD.MailOrderBuyer,WD.RCM_Score,WD.DateFromWD,WD.DateUpdated,
WD.UpdateFromWD,WD.WDScore,WD.WDRAwScore,WD.FirstName,WD.LastName,WD.FullName,WD.ADD1,WD.ADD2,WD.ADD3,WD.CITY,WD.STATE,WD.ZIP
from datawarehouse.mapping.CustomerOverlay_WD2    WD
join Datawarehouse.mapping.FBA_Merge_Dupes D
on WD.CustomerID = D.TGCPlusCustomerid + 1000000000
where  D.acctno is null
)FNL
Left join datawarehouse.mapping.CustomerOverlay_WD2 WD
on WD.CustomerID = Fnl.CustomerID
where  WD.CustomerID is null

*/

/* Load Dropped TGCPlus Customerid from mapping.TGCPlus_Merge_Dupes based on TGC customerid */
Insert into datawarehouse.mapping.CustomerOverlay_WD2
select distinct FNL.* from 
(
select TGCPlusCustomerid + 1000000000 as CustomerID,WD.MatchResult,WD.MatchResultDesc,WD.Income,WD.IncomeDescription,WD.EducationID,WD.Education,WD.BirthDate_CCYYMM,WD.BirthYear,
WD.BirthMonth,WD.DateOfBirth,WD.Gender,WD.PresenceOfChildren,WD.NetWorth,WD.MailOrderBuyer,WD.RCM_Score,WD.DateFromWD,WD.DateUpdated,
WD.UpdateFromWD,WD.WDScore,WD.WDRAwScore,WD.FirstName,WD.LastName,WD.FullName,WD.ADD1,WD.ADD2,WD.ADD3,WD.CITY,WD.STATE,WD.ZIP
from datawarehouse.mapping.CustomerOverlay_WD2    WD
join (
	select a.TGCPlusCustomerid,a.acctno  
			from  Datawarehouse.mapping.TGCPlus_Merge_Dupes a
			JOIN  (SELECT TGCPlusCustomerid,MIN(Merge_Date) Merge_Date
					FROM Datawarehouse.mapping.TGCPlus_Merge_Dupes
					WHERE Rank = 1
					GROUP BY TGCPlusCustomerid
				  )B On a.TGCPlusCustomerid = b.TGCPlusCustomerid and a.Merge_Date =b.Merge_Date and a.Rank = 1
		group by a.TGCPlusCustomerid,a.acctno
		) D
on WD.CustomerID = D.acctno
)FNL
Left join datawarehouse.mapping.CustomerOverlay_WD2 WD
on WD.CustomerID = Fnl.CustomerID
where  WD.CustomerID is null


/*Additional TGCplus to TGCPlus Matched based on Merge_Dupes file. */

/*
Insert into datawarehouse.mapping.CustomerOverlay_WD2
select distinct FNL.* from 
(
select TGCPlusCustomerid as CustomerID,WD.MatchResult,WD.MatchResultDesc,WD.Income,WD.IncomeDescription,WD.EducationID,WD.Education,WD.BirthDate_CCYYMM,WD.BirthYear,
WD.BirthMonth,WD.DateOfBirth,WD.Gender,WD.PresenceOfChildren,WD.NetWorth,WD.MailOrderBuyer,WD.RCM_Score,WD.DateFromWD,WD.DateUpdated,
WD.UpdateFromWD,WD.WDScore,WD.WDRAwScore,WD.FirstName,WD.LastName,WD.FullName,WD.ADD1,WD.ADD2,WD.ADD3,WD.CITY,WD.STATE,WD.ZIP
from datawarehouse.mapping.CustomerOverlay_WD2    WD
join (

select acctno as TGCPlusCustomerid,Keptacctno from DataWarehouse.Archive.Merge_Dupes M
	Join (select acctno as Keptacctno,keptpin 
		from DataWarehouse.Archive.Merge_Dupes
			where kept_drop='KEPT' and 
				  keptpin in 
						(
						select keptpin 
						from Datawarehouse.archive.Merge_Dupes
						--where Merge_Date ='2016-07-01'
						group by keptpin
						having min(cast(acctno as int)) between 1000000000 and 2000000000
						)  
		)K
	on K.Keptpin = M.keptpin
	and kept_drop='DROP'
		) D
on WD.CustomerID = D.Keptacctno
)FNL
Left join datawarehouse.mapping.CustomerOverlay_WD2 WD
on WD.CustomerID = Fnl.CustomerID
where  WD.CustomerID is null



*/



/* Load Dropped FBA Customerid from mapping.FBA_Merge_Dupes based on TGC customerid */
Insert into datawarehouse.mapping.CustomerOverlay_WD2
select distinct FNL.* from 
(
select FBACustomerid + 2000000000 as CustomerID,WD.MatchResult,WD.MatchResultDesc,WD.Income,WD.IncomeDescription,WD.EducationID,WD.Education,WD.BirthDate_CCYYMM,WD.BirthYear,
WD.BirthMonth,WD.DateOfBirth,WD.Gender,WD.PresenceOfChildren,WD.NetWorth,WD.MailOrderBuyer,WD.RCM_Score,WD.DateFromWD,WD.DateUpdated,
WD.UpdateFromWD,WD.WDScore,WD.WDRAwScore,WD.FirstName,WD.LastName,WD.FullName,WD.ADD1,WD.ADD2,WD.ADD3,WD.CITY,WD.STATE,WD.ZIP
from datawarehouse.mapping.CustomerOverlay_WD2    WD
join (	select a.FBACustomerid,a.acctno  
			from  Datawarehouse.mapping.FBA_Merge_Dupes a
			JOIN  (SELECT FBACustomerid,MIN(Merge_Date) Merge_Date
					FROM Datawarehouse.mapping.FBA_Merge_Dupes
					WHERE Rank = 1
					GROUP BY FBACustomerid
				  )B On a.FBACustomerid = b.FBACustomerid and a.Merge_Date =b.Merge_Date and a.Rank = 1
		group by a.FBACustomerid,a.acctno) D
on WD.CustomerID = D.acctno
)FNL
Left join datawarehouse.mapping.CustomerOverlay_WD2 WD
on WD.CustomerID = Fnl.CustomerID
where  WD.CustomerID is null


/* Load Dropped FBA Customerid from mapping.FBA_Merge_Dupes based on TGCPlus customerid */
Insert into datawarehouse.mapping.CustomerOverlay_WD2
select distinct FNL.* from 
(
select FBACustomerid + 2000000000 as CustomerID,WD.MatchResult,WD.MatchResultDesc,WD.Income,WD.IncomeDescription,WD.EducationID,WD.Education,WD.BirthDate_CCYYMM,WD.BirthYear,
WD.BirthMonth,WD.DateOfBirth,WD.Gender,WD.PresenceOfChildren,WD.NetWorth,WD.MailOrderBuyer,WD.RCM_Score,WD.DateFromWD,WD.DateUpdated,
WD.UpdateFromWD,WD.WDScore,WD.WDRAwScore,WD.FirstName,WD.LastName,WD.FullName,WD.ADD1,WD.ADD2,WD.ADD3,WD.CITY,WD.STATE,WD.ZIP
from datawarehouse.mapping.CustomerOverlay_WD2    WD
join (	select a.FBACustomerid,a.TGCPlusCustomerid  
			from  Datawarehouse.mapping.FBA_Merge_Dupes a
			JOIN  (SELECT FBACustomerid,MIN(Merge_Date) Merge_Date
					FROM Datawarehouse.mapping.FBA_Merge_Dupes
					WHERE Rank = 1 and TGCPlusCustomerid is not null and acctno is null
					GROUP BY FBACustomerid
				  )B On a.FBACustomerid = b.FBACustomerid and a.Merge_Date =b.Merge_Date and a.Rank = 1
		group by a.FBACustomerid,a.TGCPlusCustomerid) D
on WD.CustomerID = D.TGCPlusCustomerid + 1000000000
)FNL
Left join datawarehouse.mapping.CustomerOverlay_WD2 WD
on WD.CustomerID = Fnl.CustomerID
where  WD.CustomerID is null


    
 /* Insert new records*/     
 insert into DataWarehouse.Mapping.CustomerOverlay_WD    
  (CustomerID,MatchResult,MatchResultDesc,Income,IncomeDescription,EducationID,Education,BirthDate_CCYYMM,BirthYear,BirthMonth,
  DateOfBirth,Gender,PresenceOfChildren,NetWorth,MailOrderBuyer,RCM_Score,DateFromWD,DateUpdated,UpdateFromWD,WDScore,WDRawScore)
 select a.CustomerID,a.MatchResult,a.MatchResultDesc,a.Income,a.IncomeDescription,a.EducationID,a.Education,a.BirthDate_CCYYMM,a.BirthYear,a.BirthMonth,a.DateOfBirth,
 a.Gender,a.PresenceOfChildren,a.NetWorth,a.MailOrderBuyer,a.RCM_Score,a.DateFromWD,a.DateUpdated,a.UpdateFromWD,a.WDScore,a.WDRawScore    
 from DataWarehouse.Mapping.CustomerOverlay_WD2 a left join    
 DataWarehouse.Mapping.CustomerOverlay_WD b on a.CustomerID = b.CustomerID    
 where b.CustomerID is null and a.CustomerID <1000000000   
   
   
    
/* Insert new records TGC PLus*/     
 insert into DataWarehouse.Mapping.TGCPlus_CustomerOverlay     
 select a.CustomerID - 1000000000 , a.MatchResult, a.MatchResultDesc, a.Income, a.IncomeDescription,   
 a.EducationID ,a.Education, a.BirthDate_CCYYMM, a.BirthYear ,a.BirthMonth ,a.DateOfBirth,   
 a.Gender ,a.PresenceOfChildren ,a.NetWorth, a.MailOrderBuyer, a.RCM_Score,   
 a.DateFromWD ,a.DateUpdated, a.UpdateFromWD ,a.WDScore, a.WDRawScore,
 a.FirstName,a.LastName,a.FullName,a.ADD1,a.ADD2,a.ADD3,a.CITY,a.STATE,a.ZIP     
 from DataWarehouse.Mapping.CustomerOverlay_WD2 a left join    
 DataWarehouse.Mapping.TGCPlus_CustomerOverlay b on a.CustomerID = b.CustomerID + 1000000000    
 where b.CustomerID is null and a.CustomerID between 1000000000 and 2000000000


 --select * into DataWarehouse.Mapping.FBA_CustomerOverlay 
 --from DataWarehouse.Mapping.TGCPlus_CustomerOverlay
 --where 1=0


 /* Insert new records FBA*/     
 insert into DataWarehouse.Mapping.FBA_CustomerOverlay     
 select a.CustomerID - 2000000000 , a.MatchResult, a.MatchResultDesc, a.Income, a.IncomeDescription,   
 a.EducationID ,a.Education, a.BirthDate_CCYYMM, a.BirthYear ,a.BirthMonth ,a.DateOfBirth,   
 a.Gender ,a.PresenceOfChildren ,a.NetWorth, a.MailOrderBuyer, a.RCM_Score,   
 a.DateFromWD ,a.DateUpdated, a.UpdateFromWD ,a.WDScore, a.WDRawScore,
 a.FirstName,a.LastName,a.FullName,a.ADD1,a.ADD2,a.ADD3,a.CITY,a.STATE,a.ZIP     
 from DataWarehouse.Mapping.CustomerOverlay_WD2 a left join    
 DataWarehouse.Mapping.FBA_CustomerOverlay b on a.CustomerID = b.CustomerID + 2000000000    
 where b.CustomerID is null and a.CustomerID > 2000000000   

        
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
 DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID + 1000000000  = b.CustomerID      
 where b.CustomerID between 1000000000 and 2000000000

  /* Update standard Score fields FBA */    
 update a    
 set a.rcm_score = b.rcm_score,    
 a.WdScore = b.wDScore,    
 a.WdRawScore = b.wdrawscore
 from DataWarehouse.Mapping.FBA_CustomerOverlay a join    
 DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID + 2000000000  = b.CustomerID      
 where b.CustomerID > 2000000000


 /* Update TGCPLus Names and TGC plus Address's  */    
 update a    
 set  
 a.firstname = b.Firstname,  
 a.Lastname = b.Lastname,
 a.fullname = b.Fullname
 from DataWarehouse.Mapping.TGCPlus_CustomerOverlay a join    
 DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID + 1000000000  = b.CustomerID      
 where ( isnull(a.firstname,'')='' and isnull(a.firstname,'')='' ) 
 and ( isnull(b.firstname,'')<>'' or isnull(b.firstname,'')<>'' ) 
 and b.CustomerID between 1000000000 and 2000000000

 update a    
 set  
 a.address1 = b.ADD1,
 a.address2 = b.ADD2,
 a.address3 = b.ADD3,
 a.City = b.City,
 a.State = b.STATE,
 a.Zip = b.ZIP
 from DataWarehouse.Mapping.TGCPlus_CustomerOverlay a join    
 DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID + 1000000000  = b.CustomerID     
 where isnull(a.address1,'')=''  and isnull(b.ADD1,'')<>''  
 and b.CustomerID between 1000000000 and 2000000000


  /* Update FBA Names and FBA Address's  */    
 update a    
 set  
 a.firstname = b.Firstname,  
 a.Lastname = b.Lastname,
 a.fullname = b.Fullname
 from DataWarehouse.Mapping.FBA_CustomerOverlay a join    
 DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID + 2000000000  = b.CustomerID      
 where ( isnull(a.firstname,'')='' and isnull(a.firstname,'')='' ) 
 and ( isnull(b.firstname,'')<>'' or isnull(b.firstname,'')<>'' ) 
 and b.CustomerID > 2000000000

 update a    
 set  
 a.address1 = b.ADD1,
 a.address2 = b.ADD2,
 a.address3 = b.ADD3,
 a.City = b.City,
 a.State = b.STATE,
 a.Zip = b.ZIP
 from DataWarehouse.Mapping.FBA_CustomerOverlay a join    
 DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID + 2000000000  = b.CustomerID     
 where isnull(a.address1,'')=''  and isnull(b.ADD1,'')<>''  
 and b.CustomerID > 2000000000



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
 -- select count(*)
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
  a.updatefromWD = @date,
  a.firstname = b.Firstname,  
  a.Lastname = b.Lastname,
  a.fullname = b.Fullname      
 -- select count(*)
 from DataWarehouse.Mapping.TGCPlus_CustomerOverlay a join    
  DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID + 1000000000  = b.CustomerID    
 where a.MatchResult = 1     
 and b.MatchResult = 0    
 and b.CustomerID between 1000000000 and 2000000000  



 /* update previously not updated records FBA */    
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
  a.updatefromWD = @date,
  a.firstname = b.Firstname,  
  a.Lastname = b.Lastname,
  a.fullname = b.Fullname      
 -- select count(*)
 from DataWarehouse.Mapping.FBA_CustomerOverlay a join    
  DataWarehouse.Mapping.CustomerOverlay_WD2 b on a.CustomerID + 2000000000  = b.CustomerID    
 where a.MatchResult = 1     
 and b.MatchResult = 0    
 and b.CustomerID > 2000000000  
    
    
END  
GO
