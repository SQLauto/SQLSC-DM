SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_EPC_Email_PreferencePriority]      
@TableNm Varchar(255), @Priority Varchar(255)      
as      
Begin      
      
/* This SP is for Deleting Emails from Weekly Email pull Email tables when they have priority specified.       
select priority from Vw_EPC_Priority       
      
1) New Course Announcements      
2) Free Lectures, Clips and Interviews      
3) I’d like to receive all exclusive offers      
4) 2–3 per week      
5) 1 per week      
      
*/      
      
Declare @SQL nvarchar(2000)      
      
if @Priority = '1 per week'      
    
Begin       
Print 'Exclusive offers check only'    

Set @SQL = 
'   insert into Staging.EPC_Delete_Tracking 
   select Email.EmailAddress,''1 per week'',''' + @TableNm + ''', getdate() as DeletedTime
   from Lstmgr..' + @TableNm + ' Email         
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where p.ExclusiveOffers <> 1 /* Exclusive offers check only*/  
   AND Email.EmailAddress not like ''%teachco.com'''  

Print @SQL

Exec (@SQL) 
      
Set @SQL = 'Delete Email from Lstmgr..' + @TableNm + ' Email      
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where p.ExclusiveOffers <> 1 /* Exclusive offers check only*/  
   AND Email.EmailAddress not like ''%teachco.com'''  
         
Print @SQL      
      
EXEC (@SQL)      
      
END      
      
if @Priority = '2–3 per week'      
Begin       
Print 'Exclusive offers check and 2–3 per week or I’d like to receive all exclusive offers'    

Set @SQL = 
'   insert into Staging.EPC_Delete_Tracking 
   select Email.EmailAddress,''2–3 per week'',''' + @TableNm + ''', getdate() as DeletedTime
   from Lstmgr..' + @TableNm + ' Email         
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where p.ExclusiveOffers <> 1 /* Exclusive offers check and 2–3 per week or I’d like to receive all exclusive offers*/      
   Or P.Frequency in (0,3) /* 0- NO Frequency, 1- all, 2- 2-3/week, 3- 1/week */  
   AND Email.EmailAddress not like ''%teachco.com'''   

Print @SQL

Exec (@SQL)    
      
Set @SQL = 'Delete Email from Lstmgr..' + @TableNm + ' Email      
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where p.ExclusiveOffers <> 1 /* Exclusive offers check and 2–3 per week or I’d like to receive all exclusive offers*/      
   Or P.Frequency in (0,3) /* 0- NO Frequency, 1- all, 2- 2-3/week, 3- 1/week */  
   AND Email.EmailAddress not like ''%teachco.com'''   
         
Print @SQL      
      
EXEC (@SQL)      
      
END      
       
if @Priority = 'I’d like to receive all exclusive offers'      
Begin       
Print 'Exclusive offers check I’d like to receive all exclusive offers'    

Set @SQL = 
'   insert into Staging.EPC_Delete_Tracking 
   select Email.EmailAddress,''I’d like to receive all exclusive offers'',''' + @TableNm + ''', getdate() as DeletedTime
   from Lstmgr..' + @TableNm + ' Email         
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where p.ExclusiveOffers <> 1 /* Exclusive offers check I’d like to receive all exclusive offers*/      
   Or P.Frequency in (0,2,3) /* 0- NO Frequency, 1- all, 2- 2-3/week, 3- 1/week */  
   AND Email.EmailAddress not like ''%teachco.com'''   

Print @SQL

Exec (@SQL)   
      
Set @SQL = 'Delete Email from Lstmgr..' + @TableNm + ' Email      
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where p.ExclusiveOffers <> 1 /* Exclusive offers check I’d like to receive all exclusive offers*/      
   Or P.Frequency in (0,2,3) /* 0- NO Frequency, 1- all, 2- 2-3/week, 3- 1/week */  
   AND Email.EmailAddress not like ''%teachco.com'''   
         
Print @SQL      
      
EXEC (@SQL)      
      
END      
      
if @Priority = 'New Course Announcements'      
Begin       
Print ' New Course Announcements Offers check only '    

Set @SQL = '  insert into Staging.EPC_Delete_Tracking 
   select Email.EmailAddress,''New Course Announcements'',''' + @TableNm + ''', getdate() as DeletedTime
	from Lstmgr..' + @TableNm + ' Email      
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where p.NewCourseAnnouncements <> 1 /* New Course Announcements Offers check only*/  
   AND Email.EmailAddress not like ''%teachco.com'''   

Print @SQL

Exec (@SQL)   
 
Set @SQL = 'Delete Email from Lstmgr..' + @TableNm + ' Email      
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where p.NewCourseAnnouncements <> 1 /* New Course Announcements Offers check only*/  
   AND Email.EmailAddress not like ''%teachco.com'''   
  
Print @SQL      
      
EXEC (@SQL)      
      
END      
      
if @Priority = 'Free Lectures, Clips and Interviews'      
Begin       
    
Print 'Free Lectures, Clips and Interviews Offers check only'    

Set @SQL =
'  insert into Staging.EPC_Delete_Tracking 
   select Email.EmailAddress,''Free Lectures, Clips and Interviews'',''' + @TableNm + ''', getdate() as DeletedTime
   from Lstmgr..' + @TableNm + ' Email      
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where p.FreeLecturesClipsandInterviews <> 1 /* Free Lectures, Clips and Interviews Offers check only*/  
   AND Email.EmailAddress not like ''%teachco.com'''   

Print @SQL

Exec (@SQL)

      
Set @SQL = 'Delete Email from Lstmgr..' + @TableNm + ' Email      
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where p.FreeLecturesClipsandInterviews <> 1 /* Free Lectures, Clips and Interviews Offers check only*/  
   AND Email.EmailAddress not like ''%teachco.com'''   
  
Print @SQL      
      
EXEC (@SQL)      
      
END      
      
    
Print 'Exclusion list Soft Bounce/Hard Bounce/ Black List / Snooze'    


Set @SQL = 
'  insert into Staging.EPC_Delete_Tracking 
   select Email.EmailAddress,''Exclusion list Soft Bounce/Hard Bounce/ Black List / Snooze'',''' + @TableNm + ''', getdate() as DeletedTime
   from Lstmgr..' + @TableNm + ' Email      
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where P.SoftBounce = 1 Or P.HardBounce = 1 Or P.Blacklist = 1 Or P.Snoozed = 1  /* Exclusion list Soft Bounce/Hard Bounce/ Black List / Snooze */  
   AND Email.EmailAddress not like ''%teachco.com'''   

Print @SQL

Exec (@SQL)
    
Set @SQL = 'Delete Email from Lstmgr..' + @TableNm + ' Email      
   Inner join Datawarehouse.marketing.epc_preference P      
   on Email.EmailAddress = p.Email      
   where P.SoftBounce = 1 Or P.HardBounce = 1 Or P.Blacklist = 1 Or P.Snoozed = 1  /* Exclusion list Soft Bounce/Hard Bounce/ Black List / Snooze */  
   AND Email.EmailAddress not like ''%teachco.com'''   
  
Print @SQL      
      
EXEC (@SQL)      
    
    
    
END      
GO
