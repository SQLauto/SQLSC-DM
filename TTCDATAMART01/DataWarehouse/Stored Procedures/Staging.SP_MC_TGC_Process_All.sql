SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [Staging].[SP_MC_TGC_Process_All]
as
Begin

Exec Staging.SP_MC_TGC_MailContacts  ;
Print '[Staging].[SP_MC_TGC_MailContacts] Completed' 
Waitfor Delay '00:00:10';
 

Exec Staging.SP_MC_TGC_EMailContacts ;
Print 'Staging.SP_MC_TGC_EMailContacts Completed'
Waitfor Delay '00:00:10';





End
GO
