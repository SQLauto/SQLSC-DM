SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_GA_Load_Cancels]
as
Begin
     
--Delete for Rolling Days data in File.
Delete C from Marketing.TGCPLus_GA_Cancels C
join Staging.GA_ssis_Cancels S
on s.uuid = C.uuid and S.Canceldate = C.CancelDate
 
insert into Marketing.TGCPLus_GA_Cancels (UUID,Users,CancelDate,Device,DMlastupdated)
select UUID,Users,CancelDate,Device,getdate() from  Staging.GA_ssis_Cancels

End
GO
