SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_DailyDealsCleanup]
as
Begin
/*
Declare @CourseId int,@emailid Varchar(100),@startdate date

select @emailid = EmailID,@CourseId = CourseId,@startdate = cast(Startdate as date)  from mapping.Email_DailyDealsCleanup
where cast(Startdate as date) = dateadd(d,1,cast(GETDATE() as date))

select @emailid ,@CourseId,@startdate

Truncate table Lstmgr..Email_DailyDealsCleanup 

Insert into Lstmgr..Email_DailyDealsCleanup 
select Distinct @emailid EmailID,CustomerID,CourseID,@startdate as startdate
--into Lstmgr..Email_DailyDealsCleanup
from DataWarehouse.Marketing.CompleteCoursePurchase
where CourseID =  @CourseId
 
Select * from Lstmgr..Email_DailyDealsCleanup  
*/



select EmailID,CourseId,cast(Startdate as date)  startdate
Into #CourseCleanup
from mapping.Email_DailyDealsCleanup
where cast(Startdate as date) = dateadd(d,1,cast(GETDATE() as date))

select * from #CourseCleanup

Truncate table Lstmgr..Email_DailyDealsCleanup 

Insert into Lstmgr..Email_DailyDealsCleanup 
select Distinct EmailID,CustomerID,cc.CourseID,startdate
from DataWarehouse.Marketing.CompleteCoursePurchase ccp
join #CourseCleanup cc
on cc.CourseId = CCp.CourseID

 
Select top 10 * from Lstmgr..Email_DailyDealsCleanup  


Drop table #CourseCleanup

End
GO
