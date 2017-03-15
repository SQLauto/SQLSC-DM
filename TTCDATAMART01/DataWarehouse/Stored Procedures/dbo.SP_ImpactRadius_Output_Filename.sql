SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_ImpactRadius_Output_Filename] @OutputFilename varchar(200) Output  
as
Begin
set @OutputFilename = '\\file1\Shared\TGCPlus_Outgoing\ImpactRadius\'
+ 'ImpactRadius_TGC'
+ RIGHT('00'+ISNULL(convert(varchar,Datepart(dd,cast(dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) as DATE))),''),2)
+ Convert(char(3),dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) )
+ substring(cast(datepart(yyyy,dateadd(day,-7,DataWarehouse.Staging.GetSunday(getdate())) )as varchar(4)),3,4)
+'.csv'
select  @OutputFilename


End
GO
