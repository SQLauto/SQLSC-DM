SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_DRTV_Output_Filename] @OutputFilename varchar(200) Output,@SubscriptionOutputFilename varchar(200) Output
as  
Begin  
set @OutputFilename = '\\file1\Shared\TGCPlus_Outgoing\DRTV\'  
+ 'TGC'  
+ RIGHT('00'+ISNULL(convert(varchar,Datepart(dd,cast(dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) as DATE))),''),2)  
+ Convert(char(3),dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) )  
+ substring(cast(datepart(yyyy,dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) )as varchar(4)),3,4)  
+'.txt'  


set @SubscriptionOutputFilename = '\\file1\Shared\TGCPlus_Outgoing\DRTV\'  
+ 'TGC'  
+ RIGHT('00'+ISNULL(convert(varchar,Datepart(dd,cast(dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) as DATE))),''),2)  
+ Convert(char(3),dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) )  
+ substring(cast(datepart(yyyy,dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) )as varchar(4)),3,4)  
+' web.txt'  

select  @OutputFilename  ,@SubscriptionOutputFilename
  
  
End
GO
