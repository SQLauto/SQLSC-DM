SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


      
      
CREATE Proc [dbo].[Sp_NC_WelcomePackage]            
as          
Begin          
          
          
Declare @AcquisitionWeek Date ,          
        @AcquisitionWeekStart Date ,           
        @AcquisitionWeekEnd Date,          
        @CurrentWeekMonday Date ,          
        @ControlEmailType Varchar(50),          
        @TestEmailType Varchar(50),          
        @AcquisitionWeekID varchar(20),          
        @CurrentWeekMondayID varchar(20),          
        @SQL Varchar(1000)          
                      
          
--AcquisitionWeekMonday          
set @AcquisitionWeek = DateAdd(d,-7,Datawarehouse.staging.GetMonday(getdate()))          
--AcquisitionWeekSunday          
set @AcquisitionWeekStart = DATEADD(D,-1,@AcquisitionWeek)          
--AcquisitionWeekNextSunday          
set @AcquisitionWeekEnd = DATEADD(D,6,@AcquisitionWeek)          
--CurrentWeekMonday          
set @CurrentWeekMonday = Datawarehouse.staging.GetMonday(getdate())          
Set @AcquisitionWeekID =convert(char(8), @AcquisitionWeek, 112)           
Set @CurrentWeekMondayID=convert(char(8), @CurrentWeekMonday, 112)           
          
--EmailType Control version          
set @ControlEmailType = 'NCJFY69_Mailing'          
--EmailType Test version          
set @TestEmailType = null          
          
--Set Values          
print 'Set Values'          
select @AcquisitionWeek AcquisitionWeek,@AcquisitionWeekStart AcquisitionWeekStart,@AcquisitionWeekEnd AcquisitionWeekEnd          
,@CurrentWeekMonday CurrentWeekMonday,@ControlEmailType ControlEmailType,@TestEmailType TestEmailType,@AcquisitionWeekID AcquisitionWeekID, @CurrentWeekMondayID CurrentWeekMondayID          
          
if OBJECT_ID('tempdb..#temp') is not null           
Drop table #temp          
          
--For LV          
select * into #temp  from DataWarehouse.Staging.vwOrders           
where DateOrdered between @AcquisitionWeekStart and @AcquisitionWeekEnd          
          
if OBJECT_ID('tempdb..#temp2') is not null           
Drop table #temp2          
          
select distinct a.orderid, b.CustomerID, a.ITEMID          
into #temp2 from DAXImports..DAX_OrderItemExport a           
join #temp b on a.orderid = b.orderid          
where LineType = 'ItemDelivered'          
and ITEMID in ('RM0531')          
          
update a          
set a.FlagReceivedSpclShipCat  = 1,          
      A.HVLVGroup = 'LV',          
      a.ItemID = b.ITEMID          
from  DataWarehouse.Marketing.NewCustomerWelcomeSeries a join          
      #temp2 b on a.CustomerID = b.CustomerID          
                  and a.MinOrderIDinPeriod = b.orderid          
where a.AcquisitionWeek = @AcquisitionWeek          
          
          
--For MV          
if OBJECT_ID('tempdb..#tempMV') is not null           
Drop table #tempMV          
          
select * into #tempMV from DataWarehouse.Staging.vwOrders           
where DateOrdered between @AcquisitionWeekStart and @AcquisitionWeekEnd          
          
if OBJECT_ID('tempdb..#tempMV2') is not null           
Drop table #tempMV2          
          
select distinct a.orderid, b.CustomerID, a.ITEMID          
into #tempMV2          
from DAXImports..DAX_OrderItemExport a join          
#tempMV b on a.orderid = b.orderid          
where LineType = 'ItemDelivered'          
and ITEMID in ('RM0532')          
          
          
update a          
set a.FlagReceivedSpclShipCat  = 1,          
      A.HVLVGroup = 'MV',          
      a.itemid = b.ITEMID          
from  DataWarehouse.Marketing.NewCustomerWelcomeSeries (nolock) a           
join #tempMV2 b on a.CustomerID = b.CustomerID          
where a.AcquisitionWeek =  @AcquisitionWeek          
                
          
if object_id('Staging.TempNewCustomerWelcomeSeries') is not null          
Drop table [Staging].[TempNewCustomerWelcomeSeries]          
          
select NCWS.CustomerID,cast(replace(FirstName,' ','') + ' ' + replace(LastName,' ','') + ' ' + replace(Suffix,' ','') as varchar(255))AS CustomerName,      Prefix,     FirstName,  MiddleName, LastName,   Suffix          
,ccs.Address1,    cast(ccs.Address2 as varchar(100)) as Address2, ccs.City,CCS.State      Region,     PostalCode,CAST(null as varchar(10))as CouponExpire,cast (Null as int) as Adcode,CAST(null as varchar(6)) as CouponCode          
,cast (0 as int) CourseID1,   cast (0 as int) CourseID2,cast (0 as int) CourseID3,cast (0 as int)  CourseID4,cast (0 as int)     CourseID5          
,CAST(null as varchar(6)) as URLVariable,CAST(null as varchar(255)) as VersionCode,cast (0 as int) as ConvertalogAdcode,cast(CCS.FlagEmail as bit)as FlagEmailable,CCS.CustomerSegmentNew          
,cast(FlagReceivedSpclShipCat as int)FlagReceivedSpclShipCat,CAST(null as varchar(10)) as URL ,AcquisitionWeek,CustGroup  ,HVLVGroup,FlagOther         
into [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]          
from [DataWarehouse].[Marketing].[NewCustomerWelcomeSeries] NCWS (nolock)          
inner join DataWarehouse.Marketing.CampaignCustomerSignature ccs(nolock)          
on NCWS.CustomerID = CCS.CustomerID          
where NCWS.AcquisitionWeek = @AcquisitionWeek          
          
          
          
-- Make sure there are no international names          
if exists (select b.CountryCode,  COUNT(a.CustomerID)          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a join          
      DataWarehouse.Marketing.CampaignCustomerSignature b on a.customerid = b.CustomerID          
      where CountryCode<>'US'          
group by b.CountryCode)          
begin           
          
Print 'International Country names also included'          
Print 'Deleting Those which are not from US '          
          
delete a          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a           
join DataWarehouse.Marketing.CampaignCustomerSignature b on a.customerid = b.CustomerID          
where CountryCode<>'US'          
          
End          
          
          
--Update Adcode Information and URL For Control          
Update a          
Set           
a.Adcode = b.Adcode,          
a.URL = b.URL          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a          
--inner join DataWarehouse.Marketing.NewCustomerWelcomeSeries a on NCWS.CustomerID = a.CustomerID          
inner join DataWarehouse.Mapping.WelcomeEmailAdcodeGrid b on a.AcquisitionWeek = b.AcquisitionWeek          
                                                                  and a.CustGroup = b.custgroup          
                                                                  and a.HVLVGroup = b.HVLVGroup          
where a.AcquisitionWeek = @AcquisitionWeek          
and EmailType = @ControlEmailType            
          
          
/*          
--Update Adcode Information and URL For Test          
Update NCWS          
Set           
NCWS.Adcode = b.Adcode,          
NCWS.URL = b.URL          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] NCWS          
inner join DataWarehouse.Marketing.NewCustomerWelcomeSeries a on NCWS.CustomerID = a.CustomerID          
inner join DataWarehouse.Mapping.WelcomeEmailAdcodeGrid b on a.AcquisitionWeek = b.AcquisitionWeek          
                                                                  and a.CustGroup = b.custgroup          
                                                                  and a.HVLVGroup = b.HVLVGroup          
where a.AcquisitionWeek = @AcquisitionWeek          
and EmailType = @TestEmailType            
                                     
*/                                         
                                                                            
exec staging.GetAdcodeInfo_test 'staging.TempNewCustomerWelcomeSeries', DataWarehouse          
          
/*          
--Update FlagReceivedSpclShipCat          
          
update [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]           
set FlagReceivedSpclShipCat = 0          
          
update a          
set a.FlagReceivedSpclShipCat  = 1          
from  [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a join          
      (select distinct a.orderid, b.CustomerID          
      from DAXImports..DAX_OrderItemExport a join          
            (select *          
            from DataWarehouse.Staging.vwOrders           
            where DateOrdered between @AcquisitionWeekStart and @AcquisitionWeekEnd)b on a.orderid = b.orderid          
      where LineType = 'ItemDelivered'          
  and ITEMID in ('RM0531','RM0532'))b on a.CustomerID = b.CustomerID          
          
*/                                                                            
/*                                                                          
select * from DataWarehouse.Mapping.welcomeEmailAdcodeGrid           
where EmailType = 'NCJFY69_Mailing'--@ControlEmailType          
and AcquisitionWeek = '2015-05-11'--@AcquisitionWeek          
*/          
          
                
-- QC Coupon, Expiration date          
-- Coupon codes are saved in this spreadsheet..          
-- G:\Marketing\CouponCodes\WP_CATREQ_CALLCENT\Coupon Codes 2008_2012.xls          
  
/*          
Print 'Update CouponCode and CouponExpirationdate'          
          
Declare @CouponCode varchar(6),@CouponExp varchar(10)          
select @CouponCode = CouponCode,@CouponExp = ExpirationPrintedDate  from datawarehouse.Mapping.WPCoupons          
where WeekOfMailing=@CurrentWeekMonday          
and  EmailType = @ControlEmailType      
          
select @CouponCode CouponCode,@CouponExp CouponExp          
          
if @CouponCode is null or @CouponExp is null           
begin           
Print 'Coupon code is not avialble for this week'          
--Return 0          
          
end          
          
          
--Update Coupon information          
update [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]          
set CouponCode = @CouponCode,          
CouponExpire = @CouponExp          
          
*/          
          
-- qc For duplicates          
If Exists (          
SELECT distinct mail.customerid, mail.VersionCode, mail.prefix,           
      mail.firstname, mail.MiddleName, mail.lastname, mail.suffix,           
      Mail.Address1, mail.Address2, Mail.city, mail.Region, Mail.PostalCode,          
      ccs.EmailAddress          
from  [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] mail join          
      (SELECT Address1,Address2,City,Region,FirstName,LastName,Postalcode,count(customerID) custcount          
      from   [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]           
      group by Address1,Address2,City,Region,FirstName,LastName,Postalcode          
      having count(customerid) > 1)dupes on mail.address1=dupes.address1 and mail.city=dupes.city join          
      datawarehouse.Marketing.CampaignCustomerSignature ccs on mail.customerid = ccs.customerid          
   )          
          
Begin          
          
Print 'Deleting Dupes'          
          
delete from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]          
-- select * from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]          
where customerid in (          
select min(mail.customerid) customerid          
from (SELECT distinct mail.customerid, mail.prefix, ltrim(rtrim(mail.firstname)) as FirstName,           
            mail.MiddleName, ltrim(rtrim(mail.lastname))lastname, mail.suffix,           
            ltrim(rtrim(Mail.Address1)) Address1,           
            ltrim(rtrim(mail.Address2)) Address2, ltrim(rtrim(Mail.city)) City,           
            ltrim(rtrim(mail.Region)) Region, Mail.PostalCode,ccs.EmailAddress          
      from  [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] mail join          
            (SELECT Address1,Address2,City,Region,FirstName,LastName,Postalcode,count(customerID) custcount          
            from   [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]           
            group by Address1,Address2,City,Region,FirstName,LastName,Postalcode          
            having count(customerid) > 1)dupes on mail.address1=dupes.address1 and mail.city=dupes.city join          
            datawarehouse.Marketing.CampaignCustomerSignature ccs on mail.customerid = ccs.customerid)mail          
group by  mail.firstname, mail.lastname,          
            Mail.Address1, mail.address2, mail.city)          
          
End          
          
          
/* all test ids from Scott Lewis and Jay Hentry..*/          
delete  from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]          
where customerid in (51046727)          
          
          
/*backups*/          
set @SQL  = '          
     if object_id (''Marketing.NewCustomerWelcomeSeries_BKP'+ @CurrentWeekMondayID + 'DEL'') is not null          
     Drop table DataWarehouse.Marketing.NewCustomerWelcomeSeries_BKP'+ @CurrentWeekMondayID + 'DEL          
              
    select *          
                  into DataWarehouse.Marketing.NewCustomerWelcomeSeries_BKP' + @CurrentWeekMondayID + 'DEL          
                  from DataWarehouse.Marketing.NewCustomerWelcomeSeries'          
exec (@SQL)          
          
          
          
set @SQL = '          
     if object_id (''Mapping.welcomeEmailAdcodeGridBKP'+ @CurrentWeekMondayID + ''') is not null          
     Drop table DataWarehouse.Mapping.welcomeEmailAdcodeGridBKP'+ @CurrentWeekMondayID + '          
          
     select *          
                  into DataWarehouse.Mapping.welcomeEmailAdcodeGridBKP'+ @CurrentWeekMondayID +'           
                  from DataWarehouse.Mapping.welcomeEmailAdcodeGrid'           
exec (@SQL)          
          
          
-- G:\Marketing\MailfilePulls_Queries\WelcomePackage\WelcomePackageAdCodeGridUpdate_JXU20131015.xlsx          
          
/*          
INSERT INTO DataWarehouse.Mapping.welcomeEmailAdcodeGrid VALUES (89830, 'WP Catalog WK 12/30 Drop 1/10/14 PM5 Control', '5/11/2015', 'HV', 'NCJFY69_Mailing', 'CONTROL', NULL)          
INSERT INTO DataWarehouse.Mapping.welcomeEmailAdcodeGrid VALUES (89778, 'WP Catalog WK 12/30 Drop 1/10/14 PM8 Control', '5/11/2015', 'LV', 'NCJFY69_Mailing', 'CONTROL', NULL)          
*/          
          
/*          
select distinct EmailType from DataWarehouse.Mapping.welcomeEmailAdcodeGrid           
where EmailType = @ControlEmailType          
and AcquisitionWeek=@AcquisitionWeek          
          
select a.CustGroup, a.HVLVGroup, b.Adcode, convert(varchar(50),b.AdcodeName) AdcodeName, COUNT(a.customerid)          
from DataWarehouse.Marketing.NewCustomerWelcomeSeries a join          
      DataWarehouse.Mapping.WelcomeEmailAdcodeGrid b on a.AcquisitionWeek = b.AcquisitionWeek          
                                                                  and a.CustGroup = b.custgroup          
                                                                  and a.HVLVGroup = b.HVLVGroup          
where a.AcquisitionWeek =  @AcquisitionWeek          
and b.EmailType in (@ControlEmailType)          
group by a.CustGroup, a.HVLVGroup, b.Adcode, convert(varchar(50),b.AdcodeName)          
*/          
/*          
CustGroup HVLVGroup Adcode      AdcodeName                                                   
--------- --------- ----------- -------------------------------------------------- -----------          
CONTROL   HV        108959      NCC: WP Cat WK 05/04 Drop 05/15/15 PM4 Control     985          
CONTROL   LV        109069      NCC: WP Cat WK 05/04 Drop 05/15/15 PM8 Control     838          
CONTROL   MV        109014      NCC: WP Cat WK 05/04 Drop 05/15/15 PM5 Control     376          
TEST      HV        109123      NCC: WP 6x9 JFY WK 05/04 Drop 05/15/15 PM4 TEST    992          
TEST      LV        109231      NCC: WP 6x9 JFY WK 05/04 Drop 05/15/15 PM8 TEST    817          
TEST      MV        109177      NCC: WP 6x9 JFY WK 05/04 Drop 05/15/15 PM5 TEST    406          
          
(6 row(s) affected)          
          
*/          
          
/*          
select a.*, b.Adcode, b.AdcodeName          
Into #tempAdcodes          
from DataWarehouse.Marketing.NewCustomerWelcomeSeries a join          
      DataWarehouse.Mapping.WelcomeEmailAdcodeGrid b on a.AcquisitionWeek = b.AcquisitionWeek          
                                                                  and a.CustGroup = b.custgroup          
                                                                  and a.HVLVGroup = b.HVLVGroup          
where a.AcquisitionWeek =  @AcquisitionWeek          
and b.EmailType in (@ControlEmailType)          
          
update a          
set a.adcode = B.adcode          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a           
join #tempAdcodes b on a.customerid = B.customerid          
          
*/          
          
/* For the rest, include/force them in Control PM5/pm8 based on FlagReceivedSpclShipCat */          
--update a           
--set a.adcode = B.adcode           
--from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a,          
--      (select * from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid           
--      where AcquisitionWeek =  @AcquisitionWeek          
--      and EmailType = @ControlEmailType          
--      and custgroup = 'Control'          
--      and HVLVGroup = 'HV')b           
--where a.adcode = 59854          
--and FlagReceivedSpclShipCat = 0          
          
--update a           
--set a.adcode = B.adcode           
--from [Staging].[TempNewCustomerWelcomeSeries] a,          
--      (select * from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid           
--      where AcquisitionWeek = @AcquisitionWeek       
--      and EmailType = @ControlEmailType          
--      and custgroup = 'Control'          
--      and HVLVGroup = 'MV')b           
--where a.adcode = 59854          
--and FlagReceivedSpclShipCat = 1          
          
/*          
select a.adcode, b.adcodename, b.catalogcode,           
      a.FlagReceivedSpclShipCat,c.FlagReceivedSpclShipCat,          
      c.hvlvgroup, c.flagdigitalPhysical,          
      count(distinct a.customerid) CustCount          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a left outer join           
      marketingdm.dbo.adcodesall b on a.adcode = b.adcode left join          
      DataWarehouse.Marketing.NewCustomerWelcomeSeries c on a.customerid = c.customerid          
      group by a.adcode, b.adcodename, b.catalogcode, a.FlagReceivedSpclShipCat,          
            c.FlagReceivedSpclShipCat,c.HVLVGroup, c.flagdigitalPhysical          
      order by 1,5,4          
*/          
          
exec staging.GetAdcodeInfo_test 'Staging.TempNewCustomerWelcomeSeries', Datawarehouse          
/*          
adcode      adcodename                                         catalogcode CustCount          
----------- -------------------------------------------------- ----------- -----------          
18156       Control Welcome Back                               6267        527          
32640       WelcomeBack Emailable Holdouts                     6267        568          
108959      NCC: WP Cat WK 05/04 Drop 05/15/15 PM4 Control     50142       1006          
109014      NCC: WP Cat WK 05/04 Drop 05/15/15 PM5 Control     50197       369          
109069      NCC: WP Cat WK 05/04 Drop 05/15/15 PM8 Control     50252       833          
109123      NCC: WP 6x9 JFY WK 05/04 Drop 05/15/15 PM4 TEST    50306       987          
109177      NCC: WP 6x9 JFY WK 05/04 Drop 05/15/15 PM5 TEST    50360       404          
109231      NCC: WP 6x9 JFY WK 05/04 Drop 05/15/15 PM8 TEST    50414       815          
          
(8 row(s) affected)          
*/          
          
          
-- Include seeds          
insert into [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]          
select a.CustomerID, a.CustomerName,           
      a.Prefix, a.FirstName, a.MiddleName,           
      a.LastName, a.Suffix, a.Address1, a.Address2,           
      a.City, a.Region, a.PostalCode,           
      b.CouponExpire, b.Adcode, b.CouponCode,           
      b.CourseID1, b.CourseID2, b.CourseID3,           
      b.CourseID4, b.CourseID5, b.URLVariable,           
      b.VersionCode, b.ConvertalogAdcode, b.FlagEmailable,           
      b.CustomerSegmentNew, b.FlagReceivedSpclShipCat,URL,AcquisitionWeek,CustGroup  ,HVLVGroup,FlagOther           
from Datawarehouse.Mapping.SeedNames_WP a,          
      (select a.*          
      from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] A join              
            (select Adcode,custGroup,null as FlagOther, Max(CustomerID) CustomerID          
            from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]
            where custGroup='CONTROL'
            group by Adcode,custGroup
            Union 
			select Adcode,custGroup,FlagOther, Max(CustomerID) CustomerID          
            from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]   
            where custGroup='Test'       
            --Test & Test BL
            group by Adcode,custGroup ,FlagOther   
            )b on a.customerid = b.customerid)b          
order by 2                 
           
          
-- Now, you are ready to create the final file for Corp. Express          
-- Go to folder : G:\Marketing\Welcome Packages\DataFiles\2014_WP_Data          
-- select appropriate file if already there, else create a new one by copying the most recent file          
-- and remove old data with the exception of columns S, U, V, T          
-- Load the data into appropriate tabs.          
-- Put them under three different tabs          
          
          
          
If OBJECT_ID ('rfm..TempNCJFY69Mail') is not null          
Drop table rfm..TempNCJFY69Mail   


 select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, a.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM4_Control' AS PMVersion --, ConvertalogAdcode          
into rfm..TempNCJFY69Mail            
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a 
	  join datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode      
      where a.HVLVGroup = 'HV' and custgroup = 'Control'  
Union      
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, a.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM5_Control' AS PMVersion --, ConvertalogAdcode          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a 
	  join datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode      
      where a.HVLVGroup = 'MV' and custgroup = 'Control'        
Union      
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, a.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM8_Control' AS PMVersion --, ConvertalogAdcode          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a 
	  join datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode      
      where a.HVLVGroup = 'LV' and custgroup = 'Control'            
      
Union

 select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, a.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM4_Test' AS PMVersion          
      
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a 
	  join datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode      
      where a.HVLVGroup = 'HV' and custgroup = 'Test'  and FlagOther is null 
Union      
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, a.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM5_Test' AS PMVersion          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a 
	  join datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode      
      where a.HVLVGroup = 'MV' and custgroup = 'Test'  and FlagOther is null       
Union      
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, a.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM8_Test' AS PMVersion          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a 
	  join datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode      
      where a.HVLVGroup = 'LV' and custgroup = 'Test'  and FlagOther is null     
      



If OBJECT_ID ('rfm..TempNCJFY69Mail_BL') is not null          
Drop table rfm..TempNCJFY69Mail_BL   

 select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, a.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM4_Test_BL' AS PMVersion          
 into rfm..TempNCJFY69Mail_BL     
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a 
	  join datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode      
      where a.HVLVGroup = 'HV' and custgroup = 'Test'  and FlagOther = 'BL_Buyer'  
Union      
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, a.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM5_Test_BL' AS PMVersion          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a 
	  join datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode      
      where a.HVLVGroup = 'MV' and custgroup = 'Test'  and FlagOther = 'BL_Buyer'        
Union      
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, a.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM8_Test_BL' AS PMVersion          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a 
	  join datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode      
      where a.HVLVGroup = 'LV' and custgroup = 'Test'  and FlagOther = 'BL_Buyer'        
             
/*          
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, b.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM5_Control' AS PMVersion --, ConvertalogAdcode          
into rfm..TempNCJFY69Mail            
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a 
      where a.AcquisitionWeek = @AcquisitionWeek          
      and a.EmailType =  @ControlEmailType          
      and a.HVLVGroup = 'MV'          
      and custgroup = 'Control'           
union          
-- Final to Excel - Control - PM8 Group          
-- WP_Data_PM8_Adcode1          
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, b.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM8_Control' AS PMVersion --, ConvertalogAdcode          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a join          
      (select *           
      from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid           
      where AcquisitionWeek = @AcquisitionWeek          
      and EmailType = @ControlEmailType          
      and HVLVGroup = 'LV'          
                  and custgroup = 'Control')b on a.adcode = b.adcode join          
      datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode           
union          
-- Final to Excel - Test - PM4 Group          
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, b.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM4_Control' AS PMVersion --, ConvertalogAdcode          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a join          
      (select *           
      from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid           
      where AcquisitionWeek = @AcquisitionWeek          
      and EmailType = @ControlEmailType          
      and HVLVGroup = 'HV'          
                  and custgroup = 'Control')b on a.adcode = b.adcode join          
      datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode           
Union           
--Test  
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, b.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM8_Control' AS PMVersion --, ConvertalogAdcode          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a join          
      (select *           
      from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid           
      where AcquisitionWeek = @AcquisitionWeek          
      and EmailType = @ControlEmailType          
      and HVLVGroup = 'LV'          
                  and custgroup = 'Test')b on a.adcode = b.adcode join          
      datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode           
union          
-- Final to Excel - Test - PM4 Group          
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, b.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM4_Control' AS PMVersion --, ConvertalogAdcode          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a join          
      (select *           
      from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid           
      where AcquisitionWeek = @AcquisitionWeek          
      and EmailType = @ControlEmailType          
      and HVLVGroup = 'HV'          
                  and custgroup = 'Test')b on a.adcode = b.adcode join          
      datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode           
Union           
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, b.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM4_Control' AS PMVersion --, ConvertalogAdcode          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a join          
      (select *           
      from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid           
      where AcquisitionWeek = @AcquisitionWeek          
      and EmailType = @ControlEmailType          
      and HVLVGroup = 'MV'          
                  and custgroup = 'Test')b on a.adcode = b.adcode join          
      datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode  
      where FlagOther is null         

*/

/*
        
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, b.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM5_TEST' AS PMVersion --, ConvertalogAdcode          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a join          
      (select *           
      from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid           
      where AcquisitionWeek = @AcquisitionWeek          
      and EmailType =  @TestEmailType          
      and HVLVGroup = 'MV'          
                  and custgroup = 'TEST')b on a.adcode = b.adcode join          
      datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode           
union          
-- Final to Excel - TEST - PM8 Group          
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, b.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM8_TEST' AS PMVersion --, ConvertalogAdcode          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a join          
      (select *           
      from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid           
      where AcquisitionWeek = @AcquisitionWeek          
      and EmailType = @TestEmailType          
      and HVLVGroup = 'LV'          
                  and custgroup = 'TEST')b on a.adcode = b.adcode join          
      datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode           
union          
-- Final to Excel - TEST - PM4 Group          
select a.CustomerID, a.CustomerName, a.Prefix, a.FirstName, a.MiddleName, a.LastName, a.Suffix,           
      a.Address1, a.Address2, a.City, a.Region, a.PostalCode,          
      a.Adcode, b.URL,           
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate)) + ', ' + convert(varchar,year(c.stopdate))) AS  ExpirationDateYr,          
      (DATENAME(MONTH, c.StopDate) + ' ' + convert(varchar,day(c.StopDate))) AS  ExpirationDateMn,          
      'PM4_TEST' AS PMVersion --, ConvertalogAdcode          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries] a join          
      (select *           
    from DataWarehouse.Mapping.WelcomeEmailAdcodeGrid           
      where AcquisitionWeek = @AcquisitionWeek          
      and EmailType = @TestEmailType          
      and HVLVGroup = 'HV'          
                  and custgroup = 'TEST')b on a.adcode = b.adcode join          
      datawarehouse.mapping.vwadcodesall c on a.adcode = c.adcode           
          
*/          


--Final Table.          
set @SQL = '        
  if object_id (''rfm.dbo.NCJFY69Mail_'+ @CurrentWeekMondayID + '_CorpPress'') is not null          
     Drop table rfm.dbo.NCJFY69Mail_'+ @CurrentWeekMondayID + '_CorpPress           
     select * into rfm.dbo.NCJFY69Mail_' + @CurrentWeekMondayID + '_CorpPress  from rfm..TempNCJFY69Mail'          
exec (@SQL)          


set @SQL = '        
  if object_id (''rfm.dbo.NCJFY69Mail_BL_'+ @CurrentWeekMondayID + '_CorpPress'') is not null          
     Drop table rfm.dbo.NCJFY69Mail_BL_'+ @CurrentWeekMondayID + '_CorpPress           
     select * into rfm.dbo.NCJFY69Mail_BL_' + @CurrentWeekMondayID + '_CorpPress  from rfm..TempNCJFY69Mail_BL'          
exec (@SQL)   
          
                                  
-- Run this to transfer the table to the folder:          
-- \\File1\Groups\Marketing\WelcomePackages\DataFiles\2014_WP_Data          
          
--declare @SQL varchar(1000) ,@CurrentWeekMondayID varchar(100) = 'TEST'          
          
set @SQL = 'exec staging.ExportTableToPipeText rfm, dbo, NCJFY69Mail_' + @CurrentWeekMondayID + '_CorpPress, ''\\File1\Groups\Marketing\WelcomePackages\DataFiles\2016_WP_Data'''          
exec (@SQL)          


set @SQL = 'exec staging.ExportTableToPipeText rfm, dbo, NCJFY69Mail_BL_' + @CurrentWeekMondayID + '_CorpPress, ''\\File1\Groups\Marketing\WelcomePackages\DataFiles\2016_WP_Data'''          
exec (@SQL)  
      
--set @SQL = 'exec staging.ExportTableToPipeText rfm, dbo, NCJFY69Mail_' + @CurrentWeekMondayID + '_CorpPress, ''\\TTCDATAMART01\ETLDax\Reports'''          
--exec (@SQL)       
          
/*then zip up the file in the same folder with exp12# as the password          
and post it on Corp. press ftp portal.          
see the screen shot in the same folder*/          
          
          
-- Zip it up and password protect exp12#          
-- send it to corp Press.          
-- http://www.corporatepress.com/filetransfer/ftp_new.asp          
          
          
print '6 by 9 Welcome Letter Data for the week of  ' + @CurrentWeekMondayID          
print '====================================================='          
print ''          
print 'Zip: NCJFY69Mail_'+ @CurrentWeekMondayID +'_CorpPressFNL.zip'          
print ''          
print 'File: NCJFY69Mail_'+ @CurrentWeekMondayID +'_CorpPressFNL.txt'          
print ''          
          
          
set @SQL =           
'select a.PMVersion, a.adcode, b.adcodename, a.URL,           
      convert(varchar(20),a.ExpirationDateMn) ExpirationDateMn,           
      convert(varchar(25),a.ExpirationDateYr) ExpirationDateYr,           
      count(a.customerid) CustCount           
from rfm.dbo.NCJFY69Mail_' + @CurrentWeekMondayID + '_CorpPress a left outer join           
      marketingdm.dbo.adcodesall b on a.adcode = b.adcode          
group by a.PMVersion, a.adcode, b.adcodename, a.URL, convert(varchar(20),a.ExpirationDateMn),           
      convert(varchar(25),a.ExpirationDateYr)          
order by 1'          
          
Exec (@SQL)          
          
        
          
set @SQL = 'select count(*) TotalRecords          
   from rfm.dbo.NCJFY69Mail_' + @CurrentWeekMondayID + '_CorpPress'          
          
exec (@SQL)          



print '6 by 9 Welcome Letter Data for the week of  ' + @CurrentWeekMondayID          
print '====================================================='          
print ''          
print 'Zip: NCJFY69Mail_BL_'+ @CurrentWeekMondayID +'_CorpPressFNL.zip'          
print ''          
print 'File: NCJFY69Mail_BL_'+ @CurrentWeekMondayID +'_CorpPressFNL.txt'          
print ''          
          
          
set @SQL =           
'select a.PMVersion, a.adcode, b.adcodename, a.URL,           
      convert(varchar(20),a.ExpirationDateMn) ExpirationDateMn,           
      convert(varchar(25),a.ExpirationDateYr) ExpirationDateYr,           
      count(a.customerid) CustCount           
from rfm.dbo.NCJFY69Mail_BL_' + @CurrentWeekMondayID + '_CorpPress a left outer join           
      marketingdm.dbo.adcodesall b on a.adcode = b.adcode          
group by a.PMVersion, a.adcode, b.adcodename, a.URL, convert(varchar(20),a.ExpirationDateMn),           
      convert(varchar(25),a.ExpirationDateYr)          
order by 1'          
          
Exec (@SQL)          
          
       
          
set @SQL = 'select count(*) TotalRecords          
   from rfm.dbo.NCJFY69Mail_BL_' + @CurrentWeekMondayID + '_CorpPress'          
          
exec (@SQL) 


          
--Insert into History          
  print 'deletes'        
  delete from DataWarehouse.Archive.WPArchiveNew         
  where  WeekOfMailing = marketingdm.dbo.getmonday(GETDATE())          
print 'inserts into history'        
insert into DataWarehouse.Archive.WPArchiveNew          
select distinct CustomerID, CustomerName, Prefix, FirstName, MiddleName, --MiddleInitial,--          
      LastName, Suffix, Address1, Address2, City, Region,          
      PostalCode, CouponExpire, Adcode, isnull(CouponCode,''),           
      CourseID1, CourseID2, CourseID3, 0 CourseID4, 0 CourseID5,            
      marketingdm.dbo.getmonday(DATEADD(wk,-4,couponExpire)),URL          
from [DataWarehouse].[Staging].[TempNewCustomerWelcomeSeries]          
where customerid not in (12345678)          
and adcode not in (18156,32640,59854)          
          

/*Update WeekOfMailing*/
update a Set WeekOfMailing = staging.GetMonday(StartDate)
--select WeekOfMailing,staging.GetMonday(StartDate),StartDate,StopDate,count(*) 
from DataWarehouse.Archive.WPArchiveNew a
join DataWarehouse.Mapping.vwAdcodesAll b
on a .AdCode = b.AdCode
where WeekOfMailing is null
 
          
END          
          
          

GO
