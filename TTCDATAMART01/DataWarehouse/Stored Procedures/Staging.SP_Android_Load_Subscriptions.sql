SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Android_Load_Subscriptions] 
as      
Begin      

/*Update Previous Counts*/
--exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCplus_ios_events_report'
       
 
 Delete  A from Archive.TGCPlus_Android_Subscriptions A
 join staging.Android_ssis_Subscriptions S
 on S.Date = A.Date
 and S.PackageName = A.PackageName
 and S.ProductID = A.ProductID

 insert into Archive.TGCPlus_Android_Subscriptions  (Date,PackageName,ProductID,Country,NewSubscriptions,CancelledSubscriptions,ActiveSubscriptions)
 select Date,PackageName,ProductID,Country,NewSubscriptions,CancelledSubscriptions,ActiveSubscriptions
 from staging.Android_ssis_Subscriptions S


/*Update Counts*/
--exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCplus_ios_events_report'
      
END      

GO
