SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[EmailHistory_UpdateFromColo]    
 @TableName varchar(100),    
    @Date varchar(8)    
AS    
 declare @SQLStatement nvarchar(1000)    
BEGIN    
    
    set nocount on    
        
    set @SQLStatement = '    
    insert into Archive.EmailHistory (CustomerID, Adcode, StartDate, FlagHoldOut, ComboID, PreferredCategory, EmailAddress)    
 select distinct     
     Customerid,     
        Adcode,    
  cast(''' + @Date + ''' as date),    
        0,    
     case     
         when ComboID in (''Inq'', ''25-10000 Mo Inq Plus'') then ''25-10000 Mo Inq''    
            else ComboID    
     end,    
        Staging.RemoveDigits(PreferredCategory),             
  cast(EmailAddress as varchar(50)) EmailAddress  
 from lstmgr.dbo.' + @TableName + ' (nolock)    
 where Customerid between 3 and 89999999    
 and Colo_Del_Ind = 0'    
        
 exec sp_executesql @SQLStatement    
     
     
     
    set @SQLStatement = '    
    insert into Archive.EmailhistoryCurrentYear (CustomerID, Adcode, StartDate, FlagHoldOut, ComboID, PreferredCategory, EmailAddress)    
 select distinct     
     Customerid,     
        Adcode,    
  cast(''' + @Date + ''' as date),    
        0,    
     case     
         when ComboID in (''Inq'', ''25-10000 Mo Inq Plus'') then ''25-10000 Mo Inq''    
            else ComboID    
     end,    
        Staging.RemoveDigits(PreferredCategory),             
  cast(EmailAddress as varchar(50)) EmailAddress    
 from lstmgr.dbo.' + @TableName + ' (nolock)    
 where Customerid between 3 and 89999999    
 and Colo_Del_Ind = 0'    
        
 exec sp_executesql @SQLStatement     
   
/*Soft bounce Counter*/   
 set @SQLStatement = 'update SB  
       set SB.Email_Sent_Count = SB.Email_Sent_Count + 1,  
       SB.last_Email_Sent_date = getdate()-1   
       from DataWarehouse.Staging.epc_ssis_Soft_Bounce SB  
       inner join lstmgr.dbo.' + @TableName + ' E (nolock)   
       on E.Emailaddress = SB.Email  
       where Colo_Del_Ind = 0'     
  
 exec sp_executesql @SQLStatement     
  
  
/*Reset Soft bounce*/  
 Update SB  
set SB.Email_Sent_Count = 0,  
Soft_Bounce_Count = 0,  
Soft_Bounce_Flag = 0  
from DataWarehouse.Staging.epc_ssis_Soft_Bounce SB  
Where SB.Email_Sent_Count - 2 >= Soft_Bounce_Count  
  
     
END 
GO
