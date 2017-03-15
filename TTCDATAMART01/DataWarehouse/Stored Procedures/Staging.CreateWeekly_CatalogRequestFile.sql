SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CreateWeekly_CatalogRequestFile]   
 @CRDate varchar(8) = NULL,  
 @DeBugCode INT = 1  
AS  
  
/* PR - 6/4/2014 - to create monthly Course upsell file for Audible.  
  
-- Final table: rfm..CourseUpsellForAudible_YYYYMMDD  
  
-- Generates Weekly Catalog Requet Mail files  
  
*/  
  
 DECLARE @ErrorMsg VARCHAR(400),   /*- Error message for error handling.*/  
      @MailFileLog varchar(40),  
   @SQLStatement nvarchar(300),  
   @TablePrefix VARCHAR(100),  
   @MailFilePath varchar(100)  
  
   
 set @MailFilePath = '\\File1\Groups\Marketing\MailFiles\2017\US\CatalogRequests'  
  
 IF @CRDate is null select @CRDate = CONVERT(varchar,GETDATE(),112)  
  
   
    /* Check if the backend table is updated with catalog request information and if there is catalog request  
  Mailing today. */  
   
     
    IF @DeBugCode = 1 PRINT 'Check if the backend table is updated with catalog request information.'  
  
    IF NOT EXISTS (SELECT 8 FROM Mapping.CatalogRequestSchedule  
     where DataPullDate = CAST(staging.getmonday(getdate()) as DATE))  
    BEGIN   
        /* Check if we can get the DL control version of catalogcode *****/  
        Print 'There is no data in the table: Mapping.CatalogRequestSchedule. Please update and rerun.'  
        SET @ErrorMsg = 'There is no data in the table: Mapping.CatalogRequestSchedule. Please update and rerun.'  
        RAISERROR(@ErrorMsg,15,1)  
        RETURN  
    END  
      
      
    IF @DeBugCode = 1 PRINT 'Check if there is Catalog Request Mailing this week.'  
   
 DECLARE @CRCatalog varchar(25)  
   
 select @CRCatalog = CRCatalog   
 from Mapping.CatalogRequestSchedule  
 where DataPullDate = @CRDate  
   
 IF @CRCatalog = 'NO MAILING'  
    BEGIN   
        /* Check if we can get the DL control version of catalogcode *****/  
        SET @ErrorMsg = 'There is no Catalog Request Mailing this week'  
          
        select @ErrorMsg  
          
        --select @MailFileLog = 'Mail_US_CatReqLOG_' + @CRDate + '_' + @CRCatalog + '.txt'  
          
        --execute spWriteStringToFile @ErrorMsg, @MailFilePath, @MailFileLog  
        RETURN  
    END  
          
    
  
    IF @DeBugCode = 1 PRINT 'Create Catalog Request Temp table'  
      
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'CatRequest_TempFile')  
        DROP TABLE Staging.CatRequest_TempFile  
  
 select distinct JSCUSTACCT, b.Prefix, b.FirstName, b.MiddleName, b.LastName, b.Suffix,  
  b.Address1, b.Address2 + ' ' + b.Address3 as Address2,  
  b.City, b.State, b.PostalCode,  
  b.CustomerSegment, b.Frequency, b.FlagMail, b.CountryCode, b.FlagValidRegionUS  
 into Staging.CatRequest_TempFile  
 from DAXImports..JSCATALOGREQUEST a   
  join DataWarehouse.Marketing.CampaignCustomerSignature b on a.JSCUSTACCT = b.CustomerID  
 where CREATEDDATETIME >= DATEADD(week, -3, getdate())  
 and b.FlagMail = 1  
 and CountryCode = 'US'  
 and CustomerSegment like '%inq%'  
 --(289 row(s) affected)  
  
  
 -- Drop if we have already sent them a catalog  
   
    IF @DeBugCode = 1 PRINT 'Create Catalog Request History table'  
      
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'CatRequest_HistFile')  
        DROP TABLE Staging.CatRequest_HistFile  
  
 set @SQLStatement = 'select CustomerID,AdCode,NewSeg,Name,a12mf,Concatenated,FlagHoldOut,ComboID,SubjRank,PreferredCategory2,StartDate   
      into Staging.CatRequest_HistFile  
      from DataWarehouse.Archive.MailingHistory2016' + --convert(varchar,YEAR(dateadd(week, -3, getdate()))) +   
      ' where StartDate  >= DATEADD(week, -3, getdate())'  
 Print (@SQLStatement)  
 exec (@SQLStatement)  
  
 delete from Staging.CatRequest_HistFile  
 where FlagHoldOut = 1  
  
    IF @DeBugCode = 1 PRINT 'Drop if we have already sent them a catalog'  
      
 delete a  
 from Staging.CatRequest_TempFile a join  
  Staging.CatRequest_HistFile b on a.JSCUSTACCT = b.CustomerID  
   
    
 -- Drop if they have received Catalog Request in the last 4 weeks.  
    IF @DeBugCode = 1 PRINT 'Drop if they have received Catalog Request in the last 4 weeks'  
      
 delete a  
 from Staging.CatRequest_TempFile a join  
  (select *  
  from datawarehouse.Archive.MailingHistory_CatRqst  
  where datapulldate >= DATEADD(week, -5, getdate()))b on a.JSCUSTACCT = b.customerid  
    
 -- Create Final mail file  
    IF @DeBugCode = 1 PRINT 'Create Final Mail file'   
      
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'CatRequest_MailFile')  
        DROP TABLE Staging.CatRequest_MailFile  
  
 select a.JSCUSTACCT as CustomerID,  
  a.Prefix,  
  a.FirstName,  
  a.MiddleName,  
  a.LastName,  
  a.Suffix,  
  a.Address1,  
  a.Address2,  
  a.City,  
  a.State,  
  a.PostalCode,  
  b.OfferAdcode,  
  b.CatalogAdcode,  
  b.CpnExpirationDate,  
  b.CouponCode,  
  b.ShipDate  
 into Staging.CatRequest_MailFile  
   from Staging.CatRequest_TempFile a,  
   (select *   
   from datawarehouse.Mapping.CatalogRequestSchedule  
   where DataPullDate = datawarehouse.Staging.GetMonday(cast(getdate() as date))) b    
  
  
 -- Create final file for Corporate Press  
    IF @DeBugCode = 1 PRINT 'Create final file for Corporate Press'  
 declare @CatRequestTableFnl varchar(100),  
   @CatRequestFileFnl varchar(100)   
    
 select @CatRequestTableFnl = 'rfm..Mail_US_CatalogRequest_' + @CRDate + '_CorpPress'  
 select @CatRequestFileFnl = 'Mail_US_CatalogRequest_' + @CRDate + '_CorpPress'  
   
 IF EXISTS(SELECT 1 FROM rfm.sys.tables WHERE name = replace(@CatRequestTableFnl,'rfm..',''))  
  begin  
   set @SQLStatement = 'Drop table ' + @CatRequestTableFnl  
   print @SQLStatement  
   exec (@SQLStatement)      
  end  
       
 set @SQLStatement = 'select *  
    into ' + @CatRequestTableFnl +   
    ' from Staging.CatRequest_MailFile'  
     
 print @SQLStatement  
 exec (@SQLStatement)    
    
    IF @DeBugCode = 1 PRINT 'Export file to appropriate folder'    
 exec staging.ExportTableToPipeText rfm, dbo, @CatRequestFileFnl, @MailFilePath  
  
 -- Update data to history table  
 insert into datawarehouse.Archive.MailingHistory_CatRqst  
 select a.*, b.DataPullDate  
 from Staging.CatRequest_MailFile a,  
   (select *   
   from datawarehouse.Mapping.CatalogRequestSchedule  
   where DataPullDate = datawarehouse.Staging.GetMonday(cast(getdate() as date))) b  
    
    
    DROP TABLE Staging.CatRequest_TempFile  
 DROP TABLE Staging.CatRequest_HistFile  
 drop table Staging.CatRequest_MailFile  








GO
