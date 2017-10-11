SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Roku_Transactions_Load]   
as      
Begin      
    
/*Update Previous Counts*/
exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCPLus_Roku_transactions'
       
delete A from Archive.TGCPLus_Roku_transactions A
join Staging.TGCPLus_ssis_Roku_transactions S
on S.event_date = A.event_date and S.invoice_number = A.invoice_number
 

insert into Archive.TGCPLus_Roku_transactions  
select  *,getdate() as DMLastupdated
from Staging.TGCPLus_ssis_Roku_transactions

/*Update Counts*/
exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCPLus_Roku_transactions'
      
END      
GO
