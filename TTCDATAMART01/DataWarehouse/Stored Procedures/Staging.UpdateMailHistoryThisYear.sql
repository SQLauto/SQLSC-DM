SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[UpdateMailHistoryThisYear]    
 @TableName varchar(100),    
    @IsSubjectMailing char(1) = 'N'    
AS    
 declare     
     @SQLStatement nvarchar(1000)    
BEGIN    
    set nocount on    
    
  /* Update Adcode Startdate from Vwadcodesall*/  
 set @SQLStatement = '   
     Update a    
     Set a.startdate = cast(v.startdate as date)  
     from RFM..' +  @TableName +' a   
     join datawarehouse.mapping.Vwadcodesall v   
     on a.adcode = v.adcode   
     where a.adcode >10'  
 Exec sp_executesql @SQLStatement  
 set @SQLStatement = ''  
  
    if object_id('Staging.TempUpdateMailHistory') is not null drop table Staging.TempUpdateMailHistory    
    set @SQLStatement = 'select distinct *'    
  
 if not exists ( select TABLE_NAME from rfm.INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TableName and COLUMN_NAME = 'Decile')  
 begin   
  set @SQLStatement = @SQLStatement + ', null as Decile,Null as DemiDecile '  
 End  
  
    if @IsSubjectMailing = 'N' set @SQLStatement = @SQLStatement + ', '''' as SubjRank '    
 set @SQLStatement = @SQLStatement + 'into Staging.TempUpdateMailHistory from RFM..' + @TableName + ' (nolock)'        
 exec sp_executesql @SQLStatement    
        
    INSERT INTO Archive.MailhistoryCurrentYear    
    SELECT DISTINCT     
        A.CustomerID,     
        A.Adcode,     
        B.newseg,     
        b.name,     
        b.a12mf,    
        b.concatenated,     
        0 as FlagHoldout,     
        b.ComboID,     
  b.SubjRank,    
        b.PreferredCategory2,    
        B.StartDate,  
  B.Decile,  
  B.DemiDecile    
    FROM Archive.ToMH_PM_MailFile A JOIN --LEFT OUTER JOIN    
          Staging.TempUpdateMailHistory b on A.CustomerID = B.Customerid --where b.customerid is null    
     --where a.adcode in (52741,57288)--a.adcode <> 7669836     
 where a.AdCode in (select distinct AdCode from Staging.TempUpdateMailHistory (nolock))         
                  
    -- Add dropouts for catalogs    
    INSERT INTO Archive.MailhistoryCurrentYear    
    SELECT distinct     
     CustomerID,     
        Adcode,     
        NewSeg,    
        Name,     
        A12mf,     
        concatenated,     
        1,    
        ComboID,    
  SubjRank,    
        PreferredCategory2,    
        StartDate,  
  Decile,  
  DemiDecile     
    FROM Staging.TempUpdateMailHistory    
    WHERE Adcode in (SELECT distinct a.adcode    
                from Staging.TempUpdateMailHistory  A left outer JOIN    
                      Staging.mktadcodes b on A.adcode= b.adcode    
          --    where b.name like '%holdout%')    
                where b.name like '%dropout%')    
                  
    -- Add holdouts    
    INSERT INTO Archive.MailhistoryCurrentYear    
    SELECT distinct    
        CustomerID,     
        Adcode,     
        NewSeg,    
        Name,     
        A12mf,     
        concatenated,     
        1,    
        ComboID,    
  SubjRank,    
        PreferredCategory2,    
        StartDate,  
  Decile,  
  DemiDecile     
    FROM Staging.TempUpdateMailHistory    
    WHERE Adcode in (SELECT distinct a.adcode    
                from Staging.TempUpdateMailHistory  A left outer JOIN    
                      Staging.mktadcodes b on A.adcode= b.adcode    
                where b.name like '%holdout%')    
                    --where b.name like '%drop%')    
    
    if object_id('Staging.TempUpdateMailHistoryThisYear') is not null drop table Staging.TempUpdateMailHistory        
END   
  
  
GO
