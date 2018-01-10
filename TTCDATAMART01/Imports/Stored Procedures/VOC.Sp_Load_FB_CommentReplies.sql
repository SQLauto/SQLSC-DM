SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [VOC].[Sp_Load_FB_CommentReplies]  
as    
Begin    
    
--Deletes    
Delete A from VOC.FB_CommentReplies A  
join VOC.FB_SSIS_CommentReplies S  
on S.reply_id  = A.reply_id and A.original_comment_id = S.original_comment_id  
    
--Inserts    
insert into VOC.FB_CommentReplies  
(reply_id,reply_date,reply_text,original_comment_id,reply_count)    
    
select reply_id,reply_date,reply_text,original_comment_id,reply_count  
from VOC.FB_SSIS_CommentReplies  
    
End
GO
