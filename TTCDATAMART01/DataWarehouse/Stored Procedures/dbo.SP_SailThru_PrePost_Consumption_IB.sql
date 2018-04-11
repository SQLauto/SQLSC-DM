SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Proc [dbo].[SP_SailThru_PrePost_Consumption_IB] @Date Date = null
as
Begin


--declare  @Date Date = null
If @Date is null
Begin 
set @Date = Cast(getdate()-8 as date)
End 

 
 select distinct * into #Vw_map_ProfileEmailUUID from Sailthru.Mapping.Vw_map_ProfileEmailUUID


select distinct M.UUID,M.Customerid,CM.profile_id,CM.blast_id,Cast(CM.send_time as date)send_date
Into #Blast
from Sailthru..Campaign_Messages CM
Join #Vw_map_ProfileEmailUUID M
on CM.profile_id = M.ProfileID
--where Year(send_time)>=2018
where send_time >= @Date

	--select * into #TGCplus_VideoEvents_Smry 
	--from Datawarehouse.Marketing.TGCplus_VideoEvents_Smry
	--where Tstamp>= Dateadd(d,-3,@Date)
  
  select B.UUID,B.Customerid,B.profile_id,B.blast_id,B.send_date,
  /*StreamedMins*/
  Sum(Case when Datediff(D,B.send_date,VS.TSTAMP) =  -3 then VS.StreamedMins else null end) as Prior3DayStreamedMins,
  Sum(Case when Datediff(D,B.send_date,VS.TSTAMP) =  -2 then VS.StreamedMins else null end) as Prior2DayStreamedMins,
  Sum(Case when Datediff(D,B.send_date,VS.TSTAMP) =  -1 then VS.StreamedMins else null end) as Prior1DayStreamedMins,
  Sum(Case when Datediff(D,B.send_date,VS.TSTAMP) =  0  then VS.StreamedMins else null end) as CurrentDayStreamedMins,
  Sum(Case when Datediff(D,B.send_date,VS.TSTAMP) =  1  then VS.StreamedMins else null end) as Post1DayStreamedMins,
  Sum(Case when Datediff(D,B.send_date,VS.TSTAMP) =  2  then VS.StreamedMins else null end) as Post2DayStreamedMins,
  Sum(Case when Datediff(D,B.send_date,VS.TSTAMP) =  3  then VS.StreamedMins else null end) as Post3DayStreamedMins,
  /*CoursesStreamed*/
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  -3  then VS.courseid else null end) as Prior3DayCoursesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  -2  then VS.courseid else null end) as Prior2DayCoursesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  -1  then VS.courseid else null end) as Prior1DayCoursesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  0   then VS.courseid else null end) as CurrentDayCoursesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  1   then VS.courseid else null end) as Post1DayCoursesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  2   then VS.courseid else null end) as Post2DayCoursesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  3   then VS.courseid else null end) as Post3DayCoursesStreamed,
  /*LecturesStreamed*/
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  -3 then Cast(VS.courseid as Varchar(10)) + Cast(VS.episodeNumber as Varchar(10)) else null end) as Prior3DayLecturesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  -2 then Cast(VS.courseid as Varchar(10)) + Cast(VS.episodeNumber as Varchar(10)) else null end) as Prior2DayLecturesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  -1 then Cast(VS.courseid as Varchar(10)) + Cast(VS.episodeNumber as Varchar(10)) else null end) as Prior1DayLecturesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  0 then Cast(VS.courseid as Varchar(10)) + Cast(VS.episodeNumber as Varchar(10)) else null end) as CurrentDayLecturesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  1 then Cast(VS.courseid as Varchar(10)) + Cast(VS.episodeNumber as Varchar(10)) else null end) as Post1DayLecturesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  2 then Cast(VS.courseid as Varchar(10)) + Cast(VS.episodeNumber as Varchar(10)) else null end) as Post2DayLecturesStreamed,
  Count(Distinct Case when Datediff(D,B.send_date,VS.TSTAMP) =  3 then Cast(VS.courseid as Varchar(10)) + Cast(VS.episodeNumber as Varchar(10)) else null end) as Post3DayLecturesStreamed
  Into #Final
  From #Blast B
  Join Datawarehouse.Marketing.TGCplus_Consumption_Smry VS
  on B.UUID = VS.UUID
  and VS.TSTAMP Between DateAdd(d,-3,B.send_date) and DateAdd(d,3,B.send_date)
  Where episodeNumber>0 and courseid >0 
  --where Customerid = 1281905
  Group by B.UUID,B.Customerid,B.profile_id,B.blast_id,B.send_date
 
  
	Begin 
	 Delete S from Archive.TGCPlus_SailThru_blast_Streaming_IB S
	 join #Final F
	 on F.uuid = S.uuid
	 and F.profile_id = S.profile_id
	 and F.blast_id = S.blast_id
	 and F.send_date =  S.send_date


	 Insert into Archive.TGCPlus_SailThru_blast_Streaming_IB
	 (UUID,Customerid,profile_id,blast_id,send_date,
	 Prior3DayStreamedMins,Prior2DayStreamedMins,Prior1DayStreamedMins,CurrentDayStreamedMins,Post1DayStreamedMins,Post2DayStreamedMins,Post3DayStreamedMins,
	 Prior3DayCoursesStreamed,Prior2DayCoursesStreamed,Prior1DayCoursesStreamed,CurrentDayCoursesStreamed,Post1DayCoursesStreamed,Post2DayCoursesStreamed,Post3DayCoursesStreamed,
	 Prior3DayLecturesStreamed,Prior2DayLecturesStreamed,Prior1DayLecturesStreamed,CurrentDayLecturesStreamed,Post1DayLecturesStreamed,Post2DayLecturesStreamed,Post3DayLecturesStreamed)
 
	 select * from #Final

	 Drop table #Blast
	 --Drop table #TGCplus_VideoEvents_Smry
	 Drop table #Vw_map_ProfileEmailUUID
	 Drop table #Final


	End    





End
 



GO
