SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Staging].[CreateWeekly_NCJFYMailFile] 
	@PullDate date = Null,
	@DeBugCode INT = 1
AS

/* 
-- Final table: rfm..NCJFY_YYYYMMDD_CorpPress

-- PR - 8/25/2014 - to create weekly New Customer Just For You (NCJFY) mail file

*/

	DECLARE @ErrorMsg VARCHAR(400),   /*- Error message for error handling.*/
			@Count INT,
			@SQLStatement nvarchar(300),
			
			@WeekOfMailing date,
			@AcquisitionWeek date,
			@PullDateChar varchar(8)
	
	set @PullDate = coalesce(@PullDate, cast(getdate() as date))  
	
	select @PullDateChar = convert(varchar,@PullDate,112),
			@WeekOfMailing = DATEADD(WK,-6,@PullDate), 
			@AcquisitionWeek = DATEADD(WK,-7,@PullDate)
	
	select @PullDate as PullDate, 
		@PullDateChar as PullDateChar, 
		@WeekOfMailing as WeekOfMailing, 
		@AcquisitionWeek as AcquisitionWeek

	/* Check if the backend table is updated with catalog request information and if there is catalog request
		Mailing today. */
    IF @DeBugCode = 1 PRINT 'Check if the backend table is updated with NCJFY information.'

    IF NOT EXISTS (select * from Mapping.welcomeEmailAdcodeGrid
					where EmailType = 'NCJFY_Mailing'
					and AcquisitionWeek = @AcquisitionWeek)
    BEGIN	
        /* Check if we can get the DL control version of catalogcode *****/
        SET @ErrorMsg = 'There is no data in the table: Mapping.welcomeEmailAdcodeGrid for acquisition week ' + CONVERT(varchar,@AcquisitionWeek) + '. Please update and rerun.'
        RAISERROR(@ErrorMsg,15,1)
        RETURN
    END
    
    
	-- Get the list of NC JFY Adcodes for this week's mailing
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'NCJFY1')
        DROP TABLE Staging.NCJFY1

	select *
	 into Staging.NCJFY1
	from Mapping.WelcomeEmailAdcodeGrid
	where EmailType = 'NCJFY_Mailing'
	and AcquisitionWeek = @AcquisitionWeek

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'NCWP1')
        DROP TABLE Staging.NCWP1
        
	-- Get the list of Welcome Package Adcodes for this week's NCJFY customers
	select *
	into Staging.NCWP1
	from Mapping.WelcomeEmailAdcodeGrid
	where EmailType = 'WP_Mailing'
	and AcquisitionWeek = @AcquisitionWeek

        
	-- Get the list of Welcome Package Adcodes for this week's NCJFY customers

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'NCJFY1WPMap')
        DROP TABLE Staging.NCJFY1WPMap

	select a.*, b.Adcode as AdcodeWP, b.AdcodeName as AdcodeNameWP
	into staging.NCJFY1WPMap
	from Staging.NCJFY1 a join
		Staging.NCWP1 b on a.HVlvgroup = B.hvlvgroup
				and a.custgroup = b.custgroup
	


    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'NCJFY_MailFile')
        DROP TABLE Staging.NCJFY_MailFile
        
	select distinct a.CustomerID, ccs.Prefix, ccs.FirstName, ccs.MiddleName,
		ccs.LastName, ccs.Suffix, 
		ccs.Address1 + ' '  + ccs.Address2 as Address1,
	   convert(nvarchar(50), ccs.Address3) as Address2, 
		ccs.City, 
		ccs.State,
		ccs.PostalCode,
		c.Adcode,
		c.URL,
		a.AcquisitionWeek,
		a.CustGroup,
		a.HVLVGroup,
		a.JFYMailDate,
		dateadd(day,17,a.JFYMailDate) JFYStopDate,
		
		CONVERT(varchar(20),'') ExpirationDay,
		CONVERT(int,'') ExpirationYear
	into Staging.NCJFY_MailFile	
	from rfm..WPTest_Random2013 a join
		DataWarehouse.Marketing.CampaignCustomerSignature ccs on a.CustomerID = ccs.CustomerID join
		staging.NCJFY1WPMap c on a.AcquisitionWeek = c.AcquisitionWeek
						and a.CustGroup = c.CustGroup
						and a.HVLVGroup = c.hvlvgroup
	where a.AcquisitionWeek = @AcquisitionWeek
	and ccs.NewSeg in (1,2)
	and ccs.FlagMail = 1
	and a.CustGroup = 'Control'

	update Staging.NCJFY_MailFile	
	set ExpirationDay = datename(MONTH,JFYStopDate)+ ' ' + convert(varchar,day(JFYStopDate)) + 
		case when right(day(JFYStopDate),1) = '1' then 'st,'
			when left(day(JFYStopDate),1) > 1 and right(day(JFYStopDate),1) = '2' then 'nd,'
			when left(day(JFYStopDate),1) > 1 and right(day(JFYStopDate),1) ='3' then 'rd,'
			else 'th,'
		end,
		ExpirationYear = year(JFYStopDate)
	from  Staging.NCJFY_MailFile	


	-- Add seed names
	insert into Staging.NCJFY_MailFile
	select a.CustomerID, 
		a.Prefix, a.FirstName, a.MiddleName, 
		a.LastName, a.Suffix, a.Address1, a.Address2, 
		a.City, a.Region, a.PostalCode, 
		b.Adcode, b.URL, b.AcquisitionWeek, 
		b.CustGroup, b.HVLVGroup, b.JFYMailDate, 
		b.JFYStopDate, b.ExpirationDay, b.ExpirationYear
	from Mapping.SeedNames_WP a,
		(select a.*
		from Staging.NCJFY_MailFile A join	
			(select Adcode, Max(CustomerID) CustomerID
			from Staging.NCJFY_MailFile
			group by adcode)b on a.customerid = b.customerid)b
	order by b.adcode		


	-- Create Mail File to Corp.Press
	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'NCJFY_MailFile_CorpPress')
		DROP TABLE Staging.NCJFY_MailFile_CorpPress
		
	-- GET PM 4 data
	select CustomerID, Prefix, FirstName, MiddleName, LastName, Suffix, 
		Address1, Address2, City, State, PostalCode, 
		Adcode, URL, JFYMailDate, JFYStopDate, ExpirationDay, ExpirationYear,
		'PM4_HV' as PMVersion
	into Staging.NCJFY_MailFile_CorpPress	
	from Staging.NCJFY_MailFile	
	where hvlvgroup = 'HV'
	union
	-- GET PM 5 data
	select CustomerID, Prefix, FirstName, MiddleName, LastName, Suffix, 
		Address1, Address2, City, State, PostalCode, 
		Adcode, URL, JFYMailDate, JFYStopDate, ExpirationDay, ExpirationYear,
		'PM5_MV' as PMVersion
	from Staging.NCJFY_MailFile	
	where hvlvgroup = 'MV'
	union
	-- GET PM 8 data
	select CustomerID, Prefix, FirstName, MiddleName, LastName, Suffix, 
		Address1, Address2, City, State, PostalCode, 
		Adcode, URL, JFYMailDate, JFYStopDate, ExpirationDay, ExpirationYear,
		'PM8_LV' as PMVersion
	from Staging.NCJFY_MailFile	
	where hvlvgroup = 'LV'
	order by Adcode, CustomerID

	insert into DataWarehouse.Archive.MailingHistory_NCJFY
	select a.CustomerID,
		a.Adcode,
		a.URL,
		b.AcquisitionWeek,
		b.CustGroup,
		b.HVLVGroup,
		a.JFYMailDate,
		a.JFYStopDate
	 from Staging.NCJFY_MailFile_CorpPress a join
		rfm..WPTest_Random2013 b on a.CustomerID = b.CustomerID
	where a.CustomerID  <> 12345678
	
	-- Create final files for Corporate Press
	declare @NCJFYTable varchar(100),
			@NCJFYTableFnl varchar(100),
			@NCJFYFileFnl varchar(100),
			@MailFilePath varchar(100)
		
	SET @MailFilePath = '\\File1\Groups\Marketing\WelcomePackages\DataFiles\NCJFY_Data'
		
	select @NCJFYTable = 'rfm..NCJFY_' + @PullDateChar

	IF EXISTS(SELECT 1 FROM rfm.sys.tables WHERE name = replace(@NCJFYTable,'rfm..',''))
		begin
			set @SQLStatement = 'Drop table ' + @NCJFYTable
			print @SQLStatement
			exec (@SQLStatement)				
		end
		   
	set @SQLStatement = 'select *
				into ' + @NCJFYTable + 
				' from Staging.NCJFY_MailFile'
			
	print @SQLStatement
	exec (@SQLStatement)		
	
	select @NCJFYTableFnl = 'rfm..NCJFY_' + @PullDateChar + '_CorpPress'
	select @NCJFYFileFnl = 'NCJFY_' + @PullDateChar + '_CorpPress'

	IF EXISTS(SELECT 1 FROM rfm.sys.tables WHERE name = replace(@NCJFYTableFnl,'rfm..',''))	
		begin
			set @SQLStatement = 'Drop table ' + @NCJFYTableFnl
			print @SQLStatement
			exec (@SQLStatement)				
		end
		   
	set @SQLStatement = 'select *
				into ' + @NCJFYTableFnl + 
				' from Staging.NCJFY_MailFile_CorpPress'
			
	print @SQLStatement
	exec (@SQLStatement)	
		
	exec staging.ExportTableToPipeText rfm, dbo, @NCJFYFileFnl, @MailFilePath

    DROP TABLE Staging.NCJFY1
    DROP TABLE Staging.NCWP1
	DROP TABLE Staging.NCJFY1WPMap
	drop table Staging.NCJFY_MailFile
	drop table Staging.NCJFY_MailFile_CorpPress


---- run the following queries at the same time
----  and paste it in the comments section in the ftp portal
---- screen shot of corp press portal is also saved in the final mail file folder

---- copy this and paste it in comment section
--print 'NC JFY Letter Mailing'
--print '====================='
--print 'Zip: NCJFY_20140825_CorpPressFNL.zip'
--print ''
--print 'File: NCJFY_20140825_CorpPressFNL.txt'
--print ''

--select a.PMVersion, a.adcode, b.adcodename, a.URL, a.ExpirationDay, a.ExpirationYear, count(a.customerid) CustCount 
--from Staging.NCJFY_MailFile_CorpPress a left outer join 
--	marketingdm.dbo.adcodesall b on a.adcode = b.adcode
--group by a.PMVersion, a.adcode, b.adcodename, a.URL, a.ExpirationDay, a.ExpirationYear
--order by 1

/*
NC JFY Letter Mailing
=====================
Zip: NCJFY_20140825_CorpPressFNL.zip
 
File: NCJFY_20140825_CorpPressFNL.txt
 
PMVersion adcode      adcodename                                         URL        ExpirationDay        ExpirationYear CustCount
--------- ----------- -------------------------------------------------- ---------- -------------------- -------------- -----------
PM4_HV    90842       NC JFY WK 7/7 Drop 9/1 PM4 CONTROL                 DDZ        September 18th,      2014           1082
PM5_MV    90789       NC JFY WK 7/7 Drop 9/1 PM5  CONTROL                MDZ        September 18th,      2014           303
PM8_LV    90736       NC JFY WK 7/7 Drop 9/1 PM8  CONTROL                DDX        September 18th,      2014           129

(3 row(s) affected)
*/
GO
