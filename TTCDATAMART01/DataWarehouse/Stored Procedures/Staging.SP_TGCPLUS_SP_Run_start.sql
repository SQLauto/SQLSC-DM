SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_TGCPLUS_SP_Run_start] @ProcName varchar(200)
as
Begin

if @ProcName is not null
begin
Insert into Staging.TGCplus_SP_Run (ProcName)
select @ProcName
End
else 
print '@ProcName variable missing'

End
GO
