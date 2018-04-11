SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Omni_Load_Omni_AllWebUserId]     
as     
Begin    
    
    
delete from Datawarehouse.Staging.Omni_AllWebUserId    
where UserId=''    

update Datawarehouse.Staging.Omni_AllWebUserId
set PageViews = Replace([PageViews],Char(13),'') 

    
 insert into Datawarehouse.Archive.Omni_AllWebUserId     
    
 select [Date],UserId,
 cast([AllVisits] as int)AllVisits,
 cast(ProdView as int)ProdViews,
 cast([PageViews] as int)PageViews,
 getdate() as DMLastUpdated    
 from Datawarehouse.Staging.Omni_AllWebUserId  S    
 Where UserId is not NULL
 
    
End
GO
