SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

      
      
CREATE Procedure [Staging].[SP_LCM_WelcomeEmail]      
as      
      
Begin      
      
--truncate temp table      
truncate table lstmgr..TEMPLCM_WelcomeEmails2015      
      
      
--select * from LstMgr..TestLCM2015      
--select top 0 *       
--into lstmgr..TEMPLCM_WelcomeEmails2015      
--from LstMgr..TestLCM2015      
--select * from lstmgr..TEMPLCM_WelcomeEmails2015      
-- Add test ids      
-- create testID table for recurring use...      
/*      
select top 0 *       
into datawarehouse.mapping.LCM_WelcomeEmails_TestIDs      
from LstMgr..TestLCM2015      
      
alter table datawarehouse.mapping.LCM_WelcomeEmails_TestIDs      
add  Emailaddress2 varchar(40)      
*/      
-- Add test ids      
/* from Katie      
Email Address    Value      
greateourses@gmail.com HV      
mygreatcourses@gmail.com MV      
newcustomertgc@gmail.com LV      
*/      
      
/*      
truncate table DataWarehouse.Mapping.LCM_WelcomeEmails_TestIDs      
insert into DataWarehouse.Mapping.LCM_WelcomeEmails_TestIDs values ('greateourses@gmail.com','HV test','LCM email','Control','HV','greateourses')      
insert into DataWarehouse.Mapping.LCM_WelcomeEmails_TestIDs values ('greateourses@gmail.com','HV test','LCM email','Test','HV','greateourses')      
insert into DataWarehouse.Mapping.LCM_WelcomeEmails_TestIDs values ('mygreatcourses@gmail.com','MV test','LCM email','Control','MV','mygreatcourses')      
insert into DataWarehouse.Mapping.LCM_WelcomeEmails_TestIDs values ('mygreatcourses@gmail.com','MV test','LCM email','Test','MV','mygreatcourses')      
insert into DataWarehouse.Mapping.LCM_WelcomeEmails_TestIDs values ('newcustomertgc@gmail.com','LV test','LCM email','Control','LV','newcustomertgc')      
insert into DataWarehouse.Mapping.LCM_WelcomeEmails_TestIDs values ('newcustomertgc@gmail.com','LV test','LCM email','Test','LV','newcustomertgc')      
select * from DataWarehouse.Mapping.LCM_WelcomeEmails_TestIDs      
*/      
      
      
-- get last week's customers      
      
select *      
into #LastWeeksCustomers      
from rfm..WPTest_Random2013      
where datediff(week, AcquisitionWeek, GETDATE()) = 1  
    
      
--get #Adcodes    -- drop table #Adcodes  
-- select a.*, b.StartDate, b.StopDate, CONVERT(varchar(10), null) CouponCode   -- PR 1/29/2016 CouponCode being pulled from adcode grid table.    
select a.*, b.StartDate, b.StopDate 
into #Adcodes      
from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid a       
 join DataWarehouse.Mapping.vwAdcodesAll b on a.Adcode = b.AdCode      
where datediff(week, AcquisitionWeek, GETDATE()) = 1      
and EmailType like '%Email%'      
order by b.StartDate, a.CustGroup, a.HVLVGroup      
    
-- -- PR 1/29/2016 CouponCode being pulled from adcode grid table.         
--declare @CouponCode varchar(10)      
      
--select @CouponCode = CouponCode      
--from DataWarehouse.Mapping.WPCoupons      
--where datediff(week,AcquisitionWeek,GETDATE()) = 1      
--and EmailType = 'SpclOffrEmail'      
    
  
      
--update a      
--set a.Couponcode = @CouponCode      
--from #Adcodes a       
--where EmailType = 'SpclOffrEmail'      
      
   
      
--select top 0 *      
--into lstmgr..TEMPTEMPLCM_WelcomeEmails2015      
--from lstmgr..TEMPLCM_WelcomeEmails2015      
      
insert into lstmgr..TEMPLCM_WelcomeEmails2015      
select distinct a.Customerid,      
 a.EmailAddress,   
 a.FirstName,      
 a.LastName,      
 a.PreferredCategory2 as PreferredCategory,      
 b.CustGroup,       
 b.HVLVGroup,      
 b.AcquisitionWeek,      
 E1.Adcode EmailAdcode1,      
 null as EmailCouponCode1,      
 E2.Adcode EmailAdcode2,      
 E2.CouponCode as EmailCouponCode2,      
 E3.Adcode EmailAdcode3,      
 E3.CouponCode as EmailCouponCode3,      
 null as EmailAdcode4,      
 null as EmailCouponCode4,      
 null as EmailAdcode5,      
 null as EmailCouponCode5,      
 null as EmailAdcode6,      
 null as EmailCouponCode6,      
 null as EmailAdcode7,      
 null as EmailCouponCode7,      
 'N' as Unsubscribe,      
 'VALID' as EmailStatus,      
 'Email_LCMWlcmSrs' as EcampaignID,      
 Null as FlagDigitalPhysical,      
 Null as FlagAudioVedio,      
 a.CountryCode      
from Marketing.CampaignCustomerSignature a      
 join #LastWeeksCustomers b on a.CustomerID = b.CustomerID  
 left join (select *       
  from #Adcodes      
  where EmailType = 'WelcomeEmail')E1 on b.AcquisitionWeek = E1.AcquisitionWeek      
           and b.CustGroup = E1.CustGroup      
           and b.HVLVGroup = E1.HVLVGroup      
left join (select *       
  from #Adcodes      
  where EmailType = 'NCJFYEmail')E2 on b.AcquisitionWeek = E2.AcquisitionWeek      
           and b.CustGroup = E2.CustGroup      
           and b.HVLVGroup = E2.HVLVGroup      
 left join (select *       
  from #Adcodes      
  where EmailType = 'SpclOffrEmail')E3 on b.AcquisitionWeek = E3.AcquisitionWeek  /*Replaced Emailtype 3 to 4 on 8/3/2015 for next pull onwards*/    
           and b.CustGroup = E3.CustGroup      
           and b.HVLVGroup = E3.HVLVGroup      
 --left join (select *       
 -- from #Adcodes      
 -- where EmailType = 'SpclOffrEmail')E4 on b.AcquisitionWeek = E4.AcquisitionWeek      
 --          and b.CustGroup = E4.CustGroup      
 --          and b.HVLVGroup = E4.HVLVGroup      
where a.FlagEmail = 1      
and a.CountryCode = 'US'
and b.custGroup = 'Control'
UNION
select distinct a.Customerid,      
 a.EmailAddress,   
 a.FirstName,      
 a.LastName,      
 a.PreferredCategory2 as PreferredCategory,      
 b.CustGroup,       
 b.HVLVGroup,      
 b.AcquisitionWeek,      
 E1.Adcode EmailAdcode1,      
 null as EmailCouponCode1,      
 E2.Adcode EmailAdcode2,      
 E2.CouponCode as EmailCouponCode2,      
 E3.Adcode EmailAdcode3,      
 E3.CouponCode as EmailCouponCode3,      
 null as EmailAdcode4,      
 null as EmailCouponCode4,      
 null as EmailAdcode5,      
 null as EmailCouponCode5,      
 null as EmailAdcode6,      
 null as EmailCouponCode6,      
 null as EmailAdcode7,      
 null as EmailCouponCode7,      
 'N' as Unsubscribe,      
 'VALID' as EmailStatus,      
 'Email_LCMWlcmSrs' as EcampaignID,      
 Null as FlagDigitalPhysical,      
 Null as FlagAudioVedio,      
 a.CountryCode      
from Marketing.CampaignCustomerSignature a      
 join #LastWeeksCustomers b on a.CustomerID = b.CustomerID  
 left join (select *       
  from #Adcodes      
  where EmailType = 'WelcomeEmail')E1 on b.AcquisitionWeek = E1.AcquisitionWeek      
           and b.CustGroup = E1.CustGroup      
           and b.HVLVGroup = E1.HVLVGroup      
left join (select *       
  from #Adcodes      
  where EmailType = 'SpclOffrEmail')E2 on b.AcquisitionWeek = E2.AcquisitionWeek      
           and b.CustGroup = E2.CustGroup      
           and b.HVLVGroup = E2.HVLVGroup      
 left join (select *       
  from #Adcodes      
  where EmailType = 'NCJFYEmail')E3 on b.AcquisitionWeek = E3.AcquisitionWeek  /*Replaced Emailtype 3 to 4 on 8/3/2015 for next pull onwards*/    
           and b.CustGroup = E3.CustGroup      
           and b.HVLVGroup = E3.HVLVGroup      
 --left join (select *       
 -- from #Adcodes      
 -- where EmailType = 'SpclOffrEmail')E4 on b.AcquisitionWeek = E4.AcquisitionWeek      
 --          and b.CustGroup = E4.CustGroup      
 --          and b.HVLVGroup = E4.HVLVGroup      
where a.FlagEmail = 1      
and a.CountryCode = 'US'
and b.custGroup = 'Test'
and b.FlagOther is null
UNION
select distinct a.Customerid,      
 a.EmailAddress,   
 a.FirstName,      
 a.LastName,      
 a.PreferredCategory2 as PreferredCategory,      
 b.CustGroup,       
 b.HVLVGroup,      
 b.AcquisitionWeek,      
 E1.Adcode EmailAdcode1,      
 null as EmailCouponCode1,      
 E2.Adcode EmailAdcode2,      
 E2.CouponCode as EmailCouponCode2,      
 E3.Adcode EmailAdcode3,      
 E3.CouponCode as EmailCouponCode3,      
 null as EmailAdcode4,      
 null as EmailCouponCode4,      
 null as EmailAdcode5,      
 null as EmailCouponCode5,      
 null as EmailAdcode6,      
 null as EmailCouponCode6,      
 null as EmailAdcode7,      
 null as EmailCouponCode7,      
 'N' as Unsubscribe,      
 'VALID' as EmailStatus,      
 'Email_LCMWlcmSrs' as EcampaignID,      
 Null as FlagDigitalPhysical,      
 b.FlagOther as FlagAudioVedio,      
 a.CountryCode      
from Marketing.CampaignCustomerSignature a      
 join #LastWeeksCustomers b on a.CustomerID = b.CustomerID  
 left join (select *       
  from #Adcodes      
  where EmailType = 'WelcomeEmail')E1 on b.AcquisitionWeek = E1.AcquisitionWeek      
           and b.CustGroup = E1.CustGroup      
           and b.HVLVGroup = E1.HVLVGroup      
left join (select *       
  from #Adcodes      
  where EmailType = 'BLSpclOffrEmail')E2 on b.AcquisitionWeek = E2.AcquisitionWeek      
           and b.CustGroup = E2.CustGroup      
           and b.HVLVGroup = E2.HVLVGroup      
 left join (select *       
  from #Adcodes      
  where EmailType = 'NCJFYEmail')E3 on b.AcquisitionWeek = E3.AcquisitionWeek  /*Replaced Emailtype 3 to 4 on 8/3/2015 for next pull onwards*/    
           and b.CustGroup = E3.CustGroup      
           and b.HVLVGroup = E3.HVLVGroup      
 --left join (select *       
 -- from #Adcodes      
 -- where EmailType = 'SpclOffrEmail')E4 on b.AcquisitionWeek = E4.AcquisitionWeek      
 --          and b.CustGroup = E4.CustGroup      
 --          and b.HVLVGroup = E4.HVLVGroup      
where a.FlagEmail = 1      
and a.CountryCode = 'US'
and b.custGroup = 'Test'
and b.FlagOther is not null
       
       
-- add TestIDS to the table.      
      
insert into LstMgr..TEMPLCM_WelcomeEmails2015      
select (b.CustomerID * -1) CustomerID,      
 a.Emailaddress2 + '+Wk' + CONVERT(varchar,b.AcquisitionWeek,112) + '@gmail.com' as EmailAddress,      
 'TestEmail_' + a.HVLVGroup as Firstname,      
 a.CustGroup + '_' + + CONVERT(varchar,b.AcquisitionWeek,112) as Lastname,      
 b.PreferredCategory,      
 b.CustGroup,      
 b.HVLVGroup,      
 b.AcquisitionWeek,       
 b.EmailAdcode1, b.EmailCouponCode1,       
 b.EmailAdcode2, b.EmailCouponCode2,       
 b.EmailAdcode3, b.EmailCouponCode3,       
 b.EmailAdcode4, b.EmailCouponCode4,       
 b.EmailAdcode5, b.EmailCouponCode5,       
 b.EmailAdcode6, b.EmailCouponCode6,       
 b.EmailAdcode7, b.EmailCouponCode7,       
 b.Unsubscribe, b.EmailStatus, b.EcampaignID,       
 b.FlagDigitalPhysical, b.FlagAudioVideo, b.CountryCode      
from DataWarehouse.Mapping.LCM_WelcomeEmails_TestIDs a join      
 (select *      
 from lstmgr..TEMPLCM_WelcomeEmails2015      
 where CustomerID in (select MAX(customerid)      
      from lstmgr..TEMPLCM_WelcomeEmails2015      
      where datediff(week,AcquisitionWeek,GETDATE()) = 1      
      group by AcquisitionWeek, CustGroup, HVLVGroup))b on a.CustGroup = b.CustGroup      
                  and a.HVLVGroup = b.HVLVGroup      
      
      
/*      
-- QC report       
select a.AcquisitionWeek,       
 a.CountryCode,      
 a.CustGroup,      
 a.HVLVGroup,      
 a.EmailAdcode1,      
 e1.AdcodeName as Adcode1Name,      
 a.EmailCouponCode1,      
 a.EmailAdcode2,      
 e2.AdcodeName as Adcode2Name,      
 a.EmailCouponCode2,      
 a.EmailAdcode3,      
 e3.AdcodeName as Adcode3Name,      
 a.EmailCouponCode3,       
 a.EmailAdcode4,      
 e4.AdcodeName as Adcode4Name,      
 a.EmailCouponCode4,      
 count(a.customerid) CustCount      
from lstmgr..TEMPLCM_WelcomeEmails2015 a       
 left join DataWarehouse.Mapping.vwAdcodesAll e1 on a.EmailAdcode1 = e1.AdCode      
 left join DataWarehouse.Mapping.vwAdcodesAll e2 on a.EmailAdcode2 = e2.AdCode      
 left join DataWarehouse.Mapping.vwAdcodesAll e3 on a.EmailAdcode3 = e3.AdCode      
 left join DataWarehouse.Mapping.vwAdcodesAll e4 on a.EmailAdcode4 = e4.AdCode      
where datediff(week,a.AcquisitionWeek,getdate()) = 1       
group by a.AcquisitionWeek,       
 a.CountryCode,      
 a.CustGroup,      
 a.HVLVGroup,      
 a.EmailAdcode1,      
 e1.AdcodeName,      
 a.EmailCouponCode1,      
 a.EmailAdcode2,      
 e2.AdcodeName,      
 a.EmailCouponCode2,      
 a.EmailAdcode3,      
 e3.AdcodeName,      
 a.EmailCouponCode3,       
 a.EmailAdcode4,      
 e4.AdcodeName,      
 a.EmailCouponCode4      
*/      
      
-- Check for any special characters in the name field      
UPDATE lstmgr..TEMPLCM_WelcomeEmails2015      
SET FirstName = LTRIM(RTRIM(FirstName)),      
 lastname = LTRIM(RTRIM(LastName))      
where DATEDIFF(week,acquisitionweek, getdate()) = 1      
      
/*      
select * from lstmgr.dbo.TEMPLCM_WelcomeEmails2015       
where left(firstname,1) < 'a' or left(firstname,1) > 'z'      
and DATEDIFF(week,acquisitionweek, getdate()) = 1      
*/      
      
UPDATE lstmgr..TEMPLCM_WelcomeEmails2015      
SET FirstName = 'LifeLong',      
 LastName = 'Learner'      
WHERE left(firstname,1) < 'a' or left(firstname,1) > 'z'      
and DATEDIFF(week,acquisitionweek, getdate()) = 1      
      
/*      
select * from lstmgr.dbo.TEMPLCM_WelcomeEmails2015 where left(lastname,1) < 'a' or left(lastname,1) > 'z'      
and DATEDIFF(week,acquisitionweek, getdate()) = 1      
*/      
      
UPDATE lstmgr..TEMPLCM_WelcomeEmails2015      
SET FirstName = 'LifeLong',      
 LastName = 'Learner'      
WHERE left(lastname,1) < 'a' or left(lastname,1) > 'z'      
and DATEDIFF(week,acquisitionweek, getdate()) = 1      
      
/*      
select COUNT(*)      
from lstmgr..TEMPLCM_WelcomeEmails2015      
where DATEDIFF(week,acquisitionweek, getdate()) = 1      
*/      
      
      
--------------------------------------------------------------------SKIP for Testing -----------------------------------------------------------------------      
      
delete from lstmgr..LCM_WelcomeEmails2015      
where AcquisitionWeek = (select isnull(max(AcquisitionWeek),'1900-01-01') as AcquisitionWeek from lstmgr..TEMPLCM_WelcomeEmails2015)      
      
insert into lstmgr..LCM_WelcomeEmails2015      
select *      
from lstmgr..TEMPLCM_WelcomeEmails2015      
      
      
--------------------------------------------------------------------SKIP for Testing -----------------------------------------------------------------------      
      
drop table #LastWeeksCustomers      
drop table #Adcodes      
      
      
Print '     LCM QC    '      
      
Select GETDATE() as ReportDate      
      
select AcquisitionWeek, COUNT(customerid) CustomerCount      
from lstmgr..LCM_WelcomeEmails2015      
where AcquisitionWeek = (select max(AcquisitionWeek)      
                                    from lstmgr..LCM_WelcomeEmails2015)      
group by AcquisitionWeek      
order by AcquisitionWeek desc      
      
select a.AcquisitionWeek, a.CustGroup, a.HVLVGroup, EmailAdcode1, b.Name as EmailAdcode1Name,       a.EmailCouponCode1  ,
      COUNT(a.customerid) CustCount      
from lstmgr..LCM_WelcomeEmails2015 a left join      
      DataWarehouse.Staging.MktAdCodes b on a.EmailAdcode1 = b.AdCode      
where AcquisitionWeek = (select max(AcquisitionWeek)      
                                    from lstmgr..LCM_WelcomeEmails2015)      
group by a.AcquisitionWeek, a.CustGroup, a.HVLVGroup, EmailAdcode1, b.Name ,      a.EmailCouponCode1
order by 1,2,3      
            
      
select a.AcquisitionWeek, a.CustGroup, a.HVLVGroup, EmailAdcode2, b.Name as EmailAdcode2Name,      a.EmailCouponCode2  ,
      COUNT(a.customerid) CustCount      
from lstmgr..LCM_WelcomeEmails2015 a left join      
      DataWarehouse.Staging.MktAdCodes b on a.EmailAdcode2 = b.AdCode      
where AcquisitionWeek = (select max(AcquisitionWeek)      
                                    from lstmgr..LCM_WelcomeEmails2015)      
group by a.AcquisitionWeek, a.CustGroup, a.HVLVGroup, EmailAdcode2, b.Name      ,  a.EmailCouponCode2
order by 1,2,3      
      
      
select a.AcquisitionWeek, a.CustGroup, a.HVLVGroup, EmailAdcode3, b.Name as EmailAdcode3Name,       a.EmailCouponCode3  ,
      COUNT(a.customerid) CustCount      
from lstmgr..LCM_WelcomeEmails2015 a left join      
      DataWarehouse.Staging.MktAdCodes b on a.EmailAdcode3 = b.AdCode      
where AcquisitionWeek = (select max(AcquisitionWeek)      
                                    from lstmgr..LCM_WelcomeEmails2015)      
group by a.AcquisitionWeek, a.CustGroup, a.HVLVGroup, EmailAdcode3, b.Name        ,a.EmailCouponCode3
order by 1,2,3      
      
      
select a.AcquisitionWeek, a.CustGroup, a.HVLVGroup, EmailAdcode4, b.Name as EmailAdcode4Name,    a.EmailCouponCode4  ,
      COUNT(a.customerid) CustCount      
from lstmgr..LCM_WelcomeEmails2015 a left join      
      DataWarehouse.Staging.MktAdCodes b on a.EmailAdcode4 = b.AdCode      
where AcquisitionWeek = (select max(AcquisitionWeek)      
                                    from lstmgr..LCM_WelcomeEmails2015)      
group by a.AcquisitionWeek, a.CustGroup, a.HVLVGroup, EmailAdcode4, b.Name     ,a.EmailCouponCode4 
order by 1,2,3      
      
      
      
END      
      
GO
