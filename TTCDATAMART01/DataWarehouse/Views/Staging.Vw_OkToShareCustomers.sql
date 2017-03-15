SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Staging].[Vw_OkToShareCustomers]
AS
    
select *, 1 as FlagOkToShare
 FROM DAXImports..CustomerOptinExport
 where Optinid = 'OkToShare'



GO
