SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[LoadConvertalogData]
AS
-- Convertalog data for sep 2011
-- Pull Date: 10/23/2011 - Custs From 1/1/2011 to 10/22/2011 - for Oct

-- Pull Date: 9/19/2011 - Custs From 1/1/2011 to 9/19/2011 - for Sep

-- Some got dropped from July as Cust Static was not updated. To make sure
-- we include everyone, start from Jan and drop the prior recipients.
BEGIN
    set nocount on

    set transaction isolation level read uncommitted

    DROP TABLE Staging.Mail_Convertalog_NOV20111125_Wks0101to1120

    SELECT CCS.CustomerID, CCS.BuyerType, CCS.NewSeg, CCS.Name, CCS.a12mf, CCS.ComboID, CCS.Concatenated,
          CCS.CustomerSegment, CCS.Frequency, CCS.FMPullDate, '10/31/2011' StartDate, 
          CCS.Prefix, CCS.FirstName, CCS.MiddleName, CCS.LastName, CCS.Suffix, CCS.CompanyName, 
          CCS.Address1, CCS.Address2, CCS.City, CCS.State, CCS.PostalCode, 
          case when ccs.preferredcategory2 = 'VA' then 61832
                when ccs.preferredcategory2 = 'MH' then 61833
                when ccs.preferredcategory2 = 'RL' then 61834
                when ccs.preferredcategory2 = 'MSC' then 61835
                when ccs.preferredcategory2 = 'PH' then 61836
                when ccs.preferredcategory2 = 'SCI' then 61837
                when ccs.preferredcategory2 = 'AH' then 61838
                when ccs.preferredcategory2 = 'LIT' then 61839
                when ccs.preferredcategory2 = 'MTH' then 61840
                            else 61837
          end AdCode, CCS.AH, CCS.EC, CCS.FA, CCS.HS, CCS.LIT, CCS.MH, CCS.PH, CCS.RL, CCS.SC, 
          CCS.FlagMail, CCS.PreferredCategory, CCS.PreferredCategory2, CCS.PublicLibrary,
          CCS.FlagValidRegionUS, DMCS.IntlPurchaseDate, 0 as FlagWelcomeBack
    INTO Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    FROM  Marketing.CampaignCustomerSignature CCS left outer join
          Marketing.DMCustomerStatic DMCS ON CCS.CustomerID = DMCS.Customerid
    WHERE CCS.FlagMail = 1 AND CCS.PublicLibrary = 0 AND CCS.FlagValidRegionUS = 1
    AND ISNULL(CCS.Frequency,'F1') = 'F1'
    and DMCS.IntlPurchaseDate >= '1/1/2011'

    create index ix_Mail_Convertalog_OCT20111031_Wks0101to1022 on Staging.Mail_Convertalog_NOV20111125_Wks0101to1120 (customerid)

    -- Add Welcome Back folks
    INSERT INTO Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    SELECT CCS.CustomerID, CCS.BuyerType, CCS.NewSeg, CCS.Name, CCS.a12mf, CCS.ComboID, CCS.Concatenated,
          CCS.CustomerSegment, CCS.Frequency, CCS.FMPullDate, '10/31/2011' StartDate, 
          CCS.Prefix, CCS.FirstName, CCS.MiddleName, CCS.LastName, CCS.Suffix, CCS.CompanyName, 
          CCS.Address1, CCS.Address2, CCS.City, CCS.State, CCS.PostalCode, 
          case when ccs.preferredcategory2 = 'VA' then 61832
                when ccs.preferredcategory2 = 'MH' then 61833
                when ccs.preferredcategory2 = 'RL' then 61834
                when ccs.preferredcategory2 = 'MSC' then 61835
                when ccs.preferredcategory2 = 'PH' then 61836
                when ccs.preferredcategory2 = 'SCI' then 61837
                when ccs.preferredcategory2 = 'AH' then 61838
                when ccs.preferredcategory2 = 'LIT' then 61839
                when ccs.preferredcategory2 = 'MTH' then 61840
                            else 61837
          end AdCode, CCS.AH, CCS.EC, CCS.FA, CCS.HS, CCS.LIT, CCS.MH, CCS.PH, CCS.RL, CCS.SC, 
          CCS.FlagMail, CCS.PreferredCategory, CCS.PreferredCategory2, CCS.PublicLibrary,
          CCS.FlagValidRegionUS, DMCS.IntlPurchaseDate, 1 as FlagWelcomeBack
    FROM  Marketing.CampaignCustomerSignature CCS JOIN
    (select customerid
          from Staging.WPPackage10242011
          where adcode in (18156,32640)
          union
          select customerid
          from Staging.WPPackage10312011
          where adcode in (18156,32640)
          union
          select customerid
          from Staging.WPPackage11072011
          where adcode in (18156,32640)
          union
          select customerid
          from Staging.WPPackage11142011
          where adcode in (18156,32640)             
          )WBack ON CCS.CustomerID = WBack.CustomerID
          left outer join
          Marketing.DMCustomerStatic DMCS ON WBack.CustomerID = DMCS.Customerid left outer join
          Staging.Mail_Convertalog_NOV20111125_Wks0101to1120 JF on WBack.Customerid = JF.Customerid
    WHERE JF.Customerid is null
    and CCS.FlagMail = 1 AND CCS.PublicLibrary = 0 AND CCS.FlagValidRegionUS = 1 

    -- DELETE PRIOR CONVERTALOG RECIPIENTS
    delete a
    from Staging.Mail_Convertalog_NOV20111125_Wks0101to1120  a join
          Archive.MailingHistory_Convertalog b on a.customerid = b.Customerid
          
    -- Create mail file for Quad

	if object_id('Staging.Mail_Convertalog_OCT20111031_Quad') is not null
    drop TABLE Staging.Mail_Convertalog_OCT20111031_Quad

    SELECT Convert(varchar(150),
          Ltrim(rtrim(Prefix + ' ' + FirstName + ' ' + LastName + ' ' + Suffix))) FullName1,
          CompanyName as Company1, Address1 as Altrntddr1,
          Address2 AltrntAddr2, 
          convert(varchar(250),'') DLVRYDDRSS, City, State, PostalCode as Zip4, 
          Adcode as ConvertalogAdcode, 
          CustomerID, convert(varchar(50),'FRIDAY NOVEMBER 25, 2011') Expire, 
          case when isnull(PreferredCategory2,'X') in ('HS','EC','X','FW','PR','SC') 
                then convert(varchar(5),'MTH')
    --          when PreferredCategory2 = 'AH' then 'MH'
                else convert(varchar(5),PreferredCategory2)
          end SubjectCategory
    INTO Staging.Mail_Convertalog_OCT20111031_Quad
    from  Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    where adcode > 0

    update Staging.Mail_Convertalog_OCT20111031_Quad
    set expire = 'THURSDAY OCTOBER 28, 2010'

    -- Add seed list
    INSERT INTO Staging.Mail_Convertalog_OCT20111031_Quad
    select a.FullName1, '', a.Altrntddr1, '', '', a.City, a.State, a.Zip4,
          b.ConvertalogAdcode, 99999999 as CustomerID,
          b.Expire, b.SubjectCategory
    from Mapping.Convertalog_TTC_Seedlist a,
          (select distinct convertalogadcode, expire, subjectcategory
          from Staging.Mail_Convertalog_OCT20111031_Quad)b
          
    -- Add Hauser seed list only to APRch Convertalog
    INSERT INTO Staging.Mail_Convertalog_OCT20111031_Quad
    select a.FirstName + ' ' + a.LastName as FullName1, 
          '', a.Address1 as Altrntddr1, '', '', a.City, a.State, a.ZipCode as Zip4,
          b.ConvertalogAdcode, 99999999 as CustomerID,
          b.Expire, b.SubjectCategory
    from (select * from Mapping.MailFile_SeedNames_Experian 
          where adcode = 99999)a,
          (select distinct convertalogadcode, expire, subjectcategory
          from Staging.Mail_Convertalog_OCT20111031_Quad
          where convertalogAdcode = 52574)b   
          
    delete from Staging.Mail_Convertalog_OCT20111031_Quad
    where CustomerID = 99999999

    update  Staging.Mail_Convertalog_OCT20111031_Quad
    set Altrntddr1 = replace(replace(ISNULL(Altrntddr1,''),char(13),''),char(10),''),
          AltrntAddr2 = replace(replace(ISNULL(AltrntAddr2,''),char(13),''),char(10),''),
          company1 = replace(replace(ISNULL(company1,''),char(13),''),char(10),'')

    update Staging.Mail_Convertalog_OCT20111031_Quad
    set fullname1 =REPLACE(fullname1,'----','')


    update Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    set adcode = 61840
    where preferredcategory2 in ('EC','FW')
    and FlagWelcomeBack = 0

    delete
    from Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    where isnull(preferredcategory2,'HS') in ('HS','PR','X')
    and FlagWelcomeBack = 0
    
     -- drop these from welcome back folks
     insert into Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
     select * 
    from Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    where isnull(preferredcategory2,'HS') in ('EC','FW','HS','SCI','PR')
    and FlagWelcomeBack = 1

    delete
    from Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    where isnull(preferredcategory2,'HS') in ('EC','FW','HS','SCI','PR')
    and FlagWelcomeBack = 1
    
    insert into Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    select top 350 *
    from Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    where adcode = 61837
    and name is null

    delete from Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    where adcode = 61837
    and name is null

    select top 300 * 
    into #temp1
    from Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    where adcode = 61837
    and newseg = 1

    insert into Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    select * from #temp1

    delete a
    from Staging.Mail_Convertalog_NOV20111125_Wks0101to1120 a join
          #temp1 b on a.customerid = b.customerid

    --- ADD Convertalog data to convertalog history table
    insert into Archive.mailinghistory_convertalog
    select customerid, adcode, '10/31/2011', NewSeg, Name, A12mf, Concatenated, 0, ComboID, '', PreferredCategory
    from Staging.Mail_Convertalog_NOV20111125_Wks0101to1120
    
END
GO
