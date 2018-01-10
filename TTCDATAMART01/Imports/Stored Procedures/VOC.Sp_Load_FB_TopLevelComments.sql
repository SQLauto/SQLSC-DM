SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE Proc [VOC].[Sp_Load_FB_TopLevelComments]  
as    
Begin    
    
--Deletes    
Delete A from VOC.FB_TopLevelComments A  
join VOC.FB_SSIS_TopLevelComments S  
on S.post_id  = A.post_id and A.comment_id = S.comment_id  
    
--Inserts    
insert into VOC.FB_TopLevelComments  
(post_id,post_text,comment_date,comment_text,comment_likes,comment_id,post_date,comment_replies)    
    
select post_id,post_text,comment_date,comment_text,comment_likes,comment_id,post_date,comment_replies  
from VOC.FB_SSIS_TopLevelComments  
    
End  
 
GO
