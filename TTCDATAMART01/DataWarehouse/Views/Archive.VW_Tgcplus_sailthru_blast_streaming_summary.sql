SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE View [Archive].[VW_Tgcplus_sailthru_blast_streaming_summary]  
as  
select Cast(VCM.send_Datetime as date)send_Date, VCM.Campaignname,--VCM.template,VCM.list_name,  
VCM.Blast_id,  
VCM.label,
Case when NumberOfOpens>0 then 1 else 0 End as EmailOpened,  
Case when NumberOfClicks>0 then 1 else 0 End as EmailClicked,  
Count(VCM.Customerid)CustomeridCounts,   
Count(VCM.Profile_id)Profile_idCounts,   
Sum(Prior3DayStreamedMins)Prior3DayStreamedMins,  
Sum(Prior2DayStreamedMins)Prior2DayStreamedMins,  
Sum(Prior1DayStreamedMins)Prior1DayStreamedMins,   
Sum(CurrentDayStreamedMins)CurrentDayStreamedMins,   
Sum(Post1DayStreamedMins)Post1DayStreamedMins,  
Sum(Post2DayStreamedMins)Post2DayStreamedMins,  
Sum(Post3DayStreamedMins)Post3DayStreamedMins,  
Sum(Prior3DayCoursesStreamed)Prior3DayCoursesStreamed,  
Sum(Prior2DayCoursesStreamed)Prior2DayCoursesStreamed,  
Sum(Prior1DayCoursesStreamed)Prior1DayCoursesStreamed,  
Sum(CurrentDayCoursesStreamed)CurrentDayCoursesStreamed,  
Sum(Post1DayCoursesStreamed)Post1DayCoursesStreamed,  
Sum(Post2DayCoursesStreamed)Post2DayCoursesStreamed,  
Sum(Post3DayCoursesStreamed)Post3DayCoursesStreamed,  
Sum(Prior3DayLecturesStreamed ) Prior3DayLecturesStreamed,  
Sum(Prior2DayLecturesStreamed ) Prior2DayLecturesStreamed,  
Sum(Prior1DayLecturesStreamed ) Prior1DayLecturesStreamed,  
Sum(CurrentDayLecturesStreamed ) CurrentDayLecturesStreamed,  
Sum(Post1DayLecturesStreamed ) Post1DayLecturesStreamed,  
Sum(Post2DayLecturesStreamed ) Post2DayLecturesStreamed,  
Sum(Post3DayLecturesStreamed ) Post3DayLecturesStreamed  
from Sailthru..Vw_Campaign_Messages VCM  
Left join Datawarehouse.Archive.Tgcplus_sailthru_blast_streaming S  
on VCM.profile_id = S.profile_id and VCM.blast_id = S.blast_id   
Where Year(VCM.send_Datetime)>=2018  
group by Cast(VCM.send_Datetime as date),VCM.Campaignname,VCM.Blast_id,--VCM.template,VCM.list_name   
VCM.label,
Case when NumberOfOpens>0 then 1 else 0 End  ,Case when NumberOfClicks>0 then 1 else 0 End
GO
