SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [Staging].[SP_TGCPLUS_SP_Run_End] @ProcName varchar(200)
as
Begin

if @ProcName is not null
begin
update Staging.TGCplus_SP_Run 
set EndTime = getdate(),DMlastUpdated = getdate()
where ProcName = @ProcName
and EndTime is null
End
else 
print '@ProcName variable missing'

End
GO
