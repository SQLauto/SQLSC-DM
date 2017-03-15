SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
    
    
CREATE PROCEDURE [Staging].[CampaignEmail_SplitTable_NEW]    
 @TableName varchar(100),    
 @EmailName varchar(25) = 'NEW'    
AS    
Begin    
    
--declare @TableName varchar(100) = 'Emailpull_US_Email20150401_03',@EmailName varchar(25) = 'FvrtSubject'    
 declare     
    @Qry varchar(8000)    
    
    
 DECLARE @DebugCode int    
 Set @DebugCode = 1    
    
 IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TempECampaign_CreatePreTestIDS_1')    
        DROP TABLE Staging.TempECampaign_CreatePreTestIDS_1    
            
 set @Qry = 'select *     
      into Staging.TempECampaign_CreatePreTestIDS_1    
      from Staging.' + @TableName    
    
     
 if @DebugCode = 1 print (@Qry)    
     
 exec (@Qry)     
     
 delete from Staging.TempECampaign_CreatePreTestIDS_1    
 where customerid < -1     
    
 update Staging.TempECampaign_CreatePreTestIDS_1    
 set PreferredCategory = 'GEN'    
 where PreferredCategory is NULL    
    
 update Staging.TempECampaign_CreatePreTestIDS_1    
 set PreferredCategory = REPLACE(PreferredCategory,' ','')    
     
    
 IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TempECampaign_AdcodeForSplit_1')    
        DROP TABLE Staging.TempECampaign_AdcodeForSplit_1    
     
     
 select a.adcode, b.adcodename,     
    b.catalogcode, count(distinct a.customerid) CustCount,     
    convert(int,null) as TestID,    
    convert(varchar(15),'SNI') as FinalTable    
 into staging.TempECampaign_AdcodeForSplit_1    
 from Staging.TempECampaign_CreatePreTestIDS_1 a left outer join     
  Mapping.vwadcodesall b on a.adcode = b.adcode    
 group by a.adcode, b.adcodename, b.catalogcode    
 order by 1    
     
     
 select * from staging.TempECampaign_AdcodeForSplit_1    
     
 update Staging.TempECampaign_AdcodeForSplit_1    
 set FinalTable = case when AdcodeName like '%Active Control%' then  'ActiveControl'    
      when adcodename like '%Active%' then 'Active'    
      when adcodename like '%CanadaActv%' then 'Active'    
      when adcodename like '%International%' then 'Active'    
      else FinalTable    
     end    
    
 select * from staging.TempECampaign_AdcodeForSplit_1    
      
 ;WITH CTE as     
 (    
 select adcode, adcodename,     
    catalogcode, CustCount, TestID,    
 (rank() over (order by adcode)*-1) as rnk     
 from staging.TempECampaign_AdcodeForSplit_1    
 )    
    
 update CTE set TestID=rnk     
    
    
 select * from staging.TempECampaign_AdcodeForSplit_1    
    
 --DECLARE @CustHTML varchar(1000)    
 --select @CustHTML = isnull(CustHTML,'')    
 --from Staging.TempECampaign_CreatePreTestIDS_1    
 --where customerid = -1    
    
     /*- Declare MyCursor2 for adcodes */    
    DECLARE @Adcode int, @TestID int, @FinalTable varchar(15)    
        
    DECLARE MyCursor2 CURSOR    
    FOR    
    SELECT Adcode, TestID, FinalTable    
    FROM staging.TempECampaign_AdcodeForSplit_1    
    where TestID < -1    
    ORDER BY TestID desc    
     
    /*- BEGIN Second Cursor for courses within the PreferredCategory*/    
    OPEN MyCursor2    
    FETCH NEXT FROM MyCursor2 INTO @Adcode, @TestID, @FinalTable    
    
    
    WHILE @@FETCH_STATUS = 0    
    BEGIN    
    /*- Careate a test email */    
        
    Insert into Staging.TempECampaign_CreatePreTestIDS_1    
    (CustomerID,LastName,FirstName,EmailAddress,Unsubscribe,    
    Emailstatus,Subjectline,CustHTML,State,Adcode,     
    PreferredCategory, ComboID, SendDate, BatchID, EcampaignID,    
    DeadlineDate, Subject, CatalogName, CustomerSegmentNew,Userid)    
    select top 1     
  @TestID, 'Adcode_' + convert(varchar,@adcode) LastName,     
  'Testing' FirstName,     
  '~DLemailtesters@teachco.com' EmailAddress, 'N' Unsubscribe,    
  'VALID' Emailstatus, Subjectline,'' ,State, @Adcode,     
  PreferredCategory, ComboID, SendDate, BatchID, EcampaignID,    
  DeadlineDate, Subject, CatalogName, CustomerSegmentNew,    
  convert(varchar,@TestID) + '_' + EmailAddress    
 from Staging.TempECampaign_CreatePreTestIDS_1    
 where Adcode = @Adcode    
     
      
 if @FinalTable <> 'ActiveControl'    
  BEGIN    
   Insert into Staging.TempECampaign_CreatePreTestIDS_1    
   (CustomerID,LastName,FirstName,EmailAddress,Unsubscribe,    
    Emailstatus,Subjectline,CustHTML,State,Adcode,     
    PreferredCategory, ComboID, SendDate, BatchID, EcampaignID,    
    DeadlineDate, Subject, CatalogName, CustomerSegmentNew,Userid)    
   select top 1     
    (CustomerID * -1) CustomerID,  LastName,     
     FirstName,     
    '~DLemailcampaigntest@teachco.com' EmailAddress, 'N' Unsubscribe,    
    'VALID' Emailstatus, Subjectline, '', State, @Adcode,     
    PreferredCategory, ComboID, SendDate, BatchID, EcampaignID,    
    DeadlineDate, Subject, CatalogName, CustomerSegmentNew,    
    convert(varchar,(CustomerID * -1)) + '_' + EmailAddress    
   from Staging.TempECampaign_CreatePreTestIDS_1    
   where Adcode = @Adcode    
  END    
    
       
    FETCH NEXT FROM MyCursor2 INTO @Adcode, @TestID, @FinalTable    
        
    END    
    CLOSE MyCursor2    
    DEALLOCATE MyCursor2    
    /*- END Second Cursor for courses within the PreferredCategory*/    
     
-- Now add Active Test IDs    
   insert into Staging.TempECampaign_CreatePreTestIDS_1    
    (CustomerID,LastName,FirstName,EmailAddress,Unsubscribe,    
    Emailstatus,Subjectline,CustHTML,State,Adcode,     
    PreferredCategory, ComboID, SendDate, BatchID, EcampaignID,    
    DeadlineDate, Subject, CatalogName, CustomerSegmentNew,Userid)    
   select (CustomerID * -1) CustomerID,  LastName,     
     FirstName,     
    '~DLemailcampaigntest@teachco.com' EmailAddress, 'N' Unsubscribe,    
    'VALID' Emailstatus, Subjectline,'',  State, Adcode,     
    PreferredCategory, ComboID, SendDate, BatchID, EcampaignID,    
    DeadlineDate, Subject, CatalogName, CustomerSegmentNew,    
    convert(varchar,(CustomerID * -1)) + '_' + EmailAddress    
   from Staging.TempECampaign_CreatePreTestIDS_1    
   where CustomerID in  (SELECT  top 2 customerid    
        FROM Staging.TempECampaign_CreatePreTestIDS_1    
        where Adcode in (select distinct adcode     
            from  Staging.TempECampaign_AdcodeForSplit_1    
            where FinalTable = 'ActiveControl')    
        and Customerid > 0      
        order by 1 desc                 
        )    
    
       
 -- Insert test ids to main table    
 set @Qry = 'delete from Staging.' + @TableName + '     
    where customerid < -1'    
    PRINT (@Qry)    
    EXEC (@Qry)    
             
             
 set @Qry = 'insert into staging.' + @TableName + '     
    select  * from Staging.TempECampaign_CreatePreTestIDS_1    
    where customerid < -1'    
    PRINT (@Qry)    
    EXEC (@Qry)    
             
     
   /*- Create Final table*/    
    PRINT 'Create Final Tables'    
    
    DECLARE @FNLTableActive varchar(200), @FnlTableSNI varchar(200)    
              
 set @FNLTableActive = 'Lstmgr..' + @TableName +'_'+ @EmailName + '_Active'    
 set @FnlTableSNI = 'Lstmgr..' + @TableName  +'_'+ @EmailName + '_SNI'    
    
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
           ' FROM staging.' + @TableName + '     
            WHERE Adcode in (select adcode from staging.TempECampaign_AdcodeForSplit_1    
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
    
        
    
    
    SET @QRY = 'SELECT top 1 *    
        INTO SNItemp' +    
           ' FROM staging.' + @TableName + '     
            WHERE Adcode in (select adcode from staging.TempECampaign_AdcodeForSplit_1    
       where FinalTable like ''%SNI%'')'    
    PRINT (@QRY)    
    EXEC (@QRY)    
        
if exists (select top 1 * from SNItemp)    
    
begin        
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
           ' FROM staging.' + @TableName + '     
            WHERE Adcode in (select adcode from staging.TempECampaign_AdcodeForSplit_1    
       where FinalTable like ''%SNI%'')'    
    PRINT (@QRY)    
    EXEC (@QRY)    
    
    
    
    
    
    /*- Create Index on @FnlTable*/    
    
    
    SET @FnlIndex = 'IDX_' + REPLACE(@FnlTableSNI,'Lstmgr..','')    
    
    SELECT 'Create Index'    
    SET @Qry = 'CREATE CLUSTERED INDEX ' + @FnlIndex + ' ON ' + @FnlTableSNI + '(CustomerID)'    
        
    EXEC (@Qry)    
    
    
End    
    
drop table SNItemp    
    
    
END    
GO
