SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_GA_Load_Survey]
as
Begin

          
 
Delete A from archive.GA_Survey A
join Datawarehouse.staging.GA_ssis_Survey S
on a.uuid = S.uuid
and cast(A.DMLastupdated as date) between cast((getdate()-7) as date) and cast(getdate() as date)


insert into Archive.GA_Survey (UUID,Action,EventLabel,DeviceCategory,Users) 
select * from Staging.GA_ssis_Survey
 
End
GO
