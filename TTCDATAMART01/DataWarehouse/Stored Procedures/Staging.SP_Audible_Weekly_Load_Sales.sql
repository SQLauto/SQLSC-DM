SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Audible_Weekly_Load_Sales]    
as    
Begin    
    
/* Only Inserting Values*/    
  
delete A from Archive.Audible_Weekly_Sales A  
join staging.Audible_ssis_Weekly_Sales S  
on S.WeekEnding  = A.WeekEnding  
  
  
    
insert into Archive.Audible_Weekly_Sales  
select CourseID,cast(ReleaseDate as date)ReleaseDate,cast(WeekEnding as date)WeekEnding,ALaCarteUnits,ALaCarteNetPayments,
AudibleListenerUnits,AudibleListenerNetPayments,AudibleListenerOverPlanUnits,AudibleListenerOverPlanNetPayments,isnull(ALaCarteUnits,0) + isnull(AudibleListenerUnits,0) + isnull(AudibleListenerOverPlanUnits,0) as [TotalNetUnits],   
isnull(ALaCarteNetPayments,0) + isnull(AudibleListenerNetPayments,0) + isnull(AudibleListenerOverPlanNetPayments,0) as [TotalNetPayments]  
,getdate()  
from staging.Audible_ssis_Weekly_Sales  
    
End
GO
