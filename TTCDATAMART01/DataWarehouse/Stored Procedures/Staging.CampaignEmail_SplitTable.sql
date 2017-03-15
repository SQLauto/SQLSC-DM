SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CampaignEmail_SplitTable]
	@TableName varchar(100),
	@EmailName varchar(25) = 'FvrtSubject'
AS
	declare 
    @Qry varchar(8000)
BEGIN

	DECLARE @DebugCode int
	Set @DebugCode = 1

	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TempECampaign_CreatePreTestIDS')
        DROP TABLE Staging.TempECampaign_CreatePreTestIDS
        
	set @Qry = 'select * 
						into Staging.TempECampaign_CreatePreTestIDS
						from ecampaigns.dbo.' + @TableName

	
	if @DebugCode = 1 print (@Qry)
	
	exec (@Qry)	
	
	delete from Staging.TempECampaign_CreatePreTestIDS
	where customerid < -1	

	update Staging.TempECampaign_CreatePreTestIDS
	set PreferredCategory = 'GEN'
	where PreferredCategory is NULL

	update Staging.TempECampaign_CreatePreTestIDS
	set PreferredCategory = REPLACE(PreferredCategory,' ','')
	

	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TempECampaign_AdcodeForSplit')
        DROP TABLE Staging.TempECampaign_AdcodeForSplit
	
	
	select a.adcode, b.adcodename, 
				b.catalogcode, count(distinct a.customerid) CustCount, 
				convert(int,null) as TestID,
				convert(varchar(15),'SNI') as FinalTable
	into staging.TempECampaign_AdcodeForSplit
	from Staging.TempECampaign_CreatePreTestIDS a left outer join 
		Mapping.vwadcodesall b on a.adcode = b.adcode
	group by a.adcode, b.adcodename, b.catalogcode
	order by 1
	
	
	update Staging.TempECampaign_AdcodeForSplit
	set FinalTable = case when AdcodeName like '%Active Control%' then  'ActiveControl'
						when adcodename like '%Active%' then 'Active'
						when adcodename like '%CanadaActv%' then 'Active'
						when adcodename like '%International%' then 'Active'
						else FinalTable
					end

	select * from staging.TempECampaign_AdcodeForSplit
		
	;WITH CTE as 
	(
	select adcode, adcodename, 
				catalogcode, CustCount, TestID,
	(rank() over (order by adcode)*-1) as rnk 
	from staging.TempECampaign_AdcodeForSplit
	)

	update CTE set TestID=rnk 


	select * from staging.TempECampaign_AdcodeForSplit

	DECLARE @CustHTML varchar(1000)
	select @CustHTML = CustHTML
	from Staging.TempECampaign_CreatePreTestIDS
	where customerid = -1
	

     /*- Declare MyCursor2 for adcodes */
    DECLARE @Adcode int, @TestID int, @FinalTable varchar(15)
    
    DECLARE MyCursor2 CURSOR
    FOR
    SELECT Adcode, TestID, FinalTable
    FROM staging.TempECampaign_AdcodeForSplit
    where TestID < -1
    ORDER BY TestID desc
	
    /*- BEGIN Second Cursor for courses within the PreferredCategory*/
    OPEN MyCursor2
    FETCH NEXT FROM MyCursor2 INTO @Adcode, @TestID, @FinalTable


    WHILE @@FETCH_STATUS = 0
    BEGIN
    /*- Careate a test email */
    
    Insert into Staging.TempECampaign_CreatePreTestIDS
    select top 1 
		@TestID, 'Adcode_' + convert(varchar,@adcode) LastName, 
		'Testing' FirstName, 
		'~DLemailtesters@teachco.com' EmailAddress, 'N' Unsubscribe,
		'VALID' Emailstatus, Subjectline, @CustHTML as CustHTML, State, @Adcode, 
		PreferredCategory, ComboID, SendDate, BatchID, EcampaignID,
		DeadlineDate, Subject, CatalogName, CustomerSegmentNew,
		convert(varchar,@TestID) + '_' + CONVERT(varchar,@Adcode)
	from Staging.TempECampaign_CreatePreTestIDS
	where Adcode = @Adcode
	
  
	if @FinalTable <> 'ActiveControl'
		BEGIN
			Insert into Staging.TempECampaign_CreatePreTestIDS
			select top 5 
				(CustomerID * -1) CustomerID,  LastName, 
				 FirstName, 
				'~DLemailcampaigntest@teachco.com' EmailAddress, 'N' Unsubscribe,
				'VALID' Emailstatus, Subjectline, CustHTML, State, @Adcode, 
				PreferredCategory, ComboID, SendDate, BatchID, EcampaignID,
				DeadlineDate, Subject, CatalogName, CustomerSegmentNew,
				convert(varchar,(CustomerID * -1)) + '_' + CONVERT(varchar,@Adcode)
			from Staging.TempECampaign_CreatePreTestIDS
			where Adcode = @Adcode
		END

			
    FETCH NEXT FROM MyCursor2 INTO @Adcode, @TestID, @FinalTable
    
    END
    CLOSE MyCursor2
    DEALLOCATE MyCursor2
    /*- END Second Cursor for courses within the PreferredCategory*/
	
-- Now add Active Test IDs
			Insert into Staging.TempECampaign_CreatePreTestIDS
			select (CustomerID * -1) CustomerID,  LastName, 
				 FirstName, 
				'~DLemailcampaigntest@teachco.com' EmailAddress, 'N' Unsubscribe,
				'VALID' Emailstatus, Subjectline, CustHTML, State, Adcode, 
				PreferredCategory, ComboID, SendDate, BatchID, EcampaignID,
				DeadlineDate, Subject, CatalogName, CustomerSegmentNew,
				convert(varchar,(CustomerID * -1)) + '_' + CONVERT(varchar,Adcode)
			from Staging.TempECampaign_CreatePreTestIDS
			where CustomerID in  (SELECT MAX(DISTINCT customerid) AS customerid
								FROM Staging.TempECampaign_CreatePreTestIDS
								where Adcode in (select distinct adcode	
												from  Staging.TempECampaign_AdcodeForSplit
												where FinalTable = 'ActiveControl')
								and Customerid > 0															
								GROUP BY PreferredCategory,Adcode)

			
	-- Insert test ids to main table
	set @Qry = 'delete from Ecampaigns..' + @TableName + ' 
				where customerid < -1'
    PRINT (@Qry)
    EXEC (@Qry)
        	
        	
	set @Qry = 'insert into Ecampaigns..' + @TableName + ' 
				select  * from Staging.TempECampaign_CreatePreTestIDS
				where customerid < -1'
    PRINT (@Qry)
    EXEC (@Qry)
        	
	
	  /*- Create Final table*/
    PRINT 'Create Final Tables'

    DECLARE @FNLTableActive varchar(200), @FnlTableSNI varchar(200)
	    	    
	set @FNLTableActive = 'Lstmgr..Email_' + convert(varchar,SUBSTRING(@TableName,6,8)) + '_' + @EmailName + '_Active'
	set @FnlTableSNI = 'Lstmgr..Email_' + convert(varchar,SUBSTRING(@TableName,6,8)) + '_' + @EmailName + '_SNI'

	PRINT '-------------------------------------------------------------'
	PRINT 'Final tables are:'
	PRINT @FNLTableActive + ' and ' + @FnlTableSNI
	PRINT '-------------------------------------------------------------'

    IF (EXISTS (SELECT * FROM Lstmgr.INFORMATION_SCHEMA.TABLES        
                WHERE TABLE_CATALOG = 'Lstmgr'
                AND TABLE_SCHEMA = 'dbo'
                AND TABLE_NAME = REPLACE(@FNLTableActive,'Lstmgr..','')))
    BEGIN
        SET @Qry = 'DROP TABLE ' + @FNLTableActive
        PRINT @Qry
        EXEC (@Qry)
    END


    SET @QRY = 'SELECT *
        INTO ' + @FNLTableActive +
           ' FROM Ecampaigns..' + @TableName + ' 
            WHERE Adcode in (select adcode from staging.TempECampaign_AdcodeForSplit
							where FinalTable like ''%active%'')'
    PRINT (@QRY)
    EXEC (@QRY)


    /*- Create Index on @FnlTable*/
    DECLARE @FnlIndex VARCHAR(50)

    SET @FnlIndex = 'IDX_' + REPLACE(@FNLTableActive,'Lstmgr..','')

    SELECT 'Create Index'
    SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FNLTableActive + '(CustomerID)'
    EXEC (@Qry)

    /*- Drop if @FnlTablSNI already exists*/

    /*SELECT @RowCounts = COUNT(*) FROM sysobjects*/
    /*WHERE Name = @FnlTableSNI*/
    /*SELECT '@RowCounts = ' + CONVERT(VARCHAR,@RowCounts)*/

    IF (EXISTS (SELECT * FROM Lstmgr.INFORMATION_SCHEMA.TABLES        
                WHERE TABLE_CATALOG = 'Lstmgr'
                AND TABLE_SCHEMA = 'dbo'
                AND TABLE_NAME = REPLACE(@FnlTableSNI,'Lstmgr..','')))
    BEGIN
        SET @Qry = 'DROP TABLE ' + @FnlTableSNI
        SELECT @Qry
        EXEC (@Qry)
    END


    SET @QRY = 'SELECT *
        INTO ' + @FnlTableSNI +
           ' FROM Ecampaigns..' + @TableName + ' 
            WHERE Adcode in (select adcode from staging.TempECampaign_AdcodeForSplit
							where FinalTable like ''%SNI%'')'
    PRINT (@QRY)
    EXEC (@QRY)


    /*- Create Index on @FnlTable*/


    SET @FnlIndex = 'IDX_' + REPLACE(@FnlTableSNI,'Lstmgr..','')

    SELECT 'Create Index'
    SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTableSNI + '(CustomerID)'
    
    EXEC (@Qry)



END
GO
