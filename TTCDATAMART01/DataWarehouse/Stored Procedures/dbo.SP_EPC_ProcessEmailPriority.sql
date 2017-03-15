SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[SP_EPC_ProcessEmailPriority]
as

Begin
/* insert into DataWarehouse.Staging.epc_email_log new email tables */

insert into DataWarehouse.Staging.epc_email_log
(EmailTable,Priority,EmailSendDate)
select a. EmailTable,a.Priority,a.Startdate  from (
select distinct 'EPC_' + EmailId + '_NEW_Active' as EmailTable,Priority,Startdate from DataWarehouse.Mapping.email_adcode
union 
select distinct 'EPC_' + EmailId + '_NEW_SNI' as EmailTable,Priority,Startdate from DataWarehouse.Mapping.email_adcode
where EmailId like '%_US_%'
)a
left join DataWarehouse.Staging.epc_email_log L
on a.EmailTable = L.EmailTable
where L.EmailTable is null

/* Emails that Dont have SNI Table*/
select * from DataWarehouse.Staging.epc_email_log
where EmailTable not in 
(
select name from lstmgr.Sys.tables 
where type = 'U'
)

delete from DataWarehouse.Staging.epc_email_log
where EmailTable not in 
(
select name from lstmgr.Sys.tables 
where type = 'U'
)


/*Process Email tables with Priority*/

Declare @Pepc_email_log_id int, @PEmailTable varchar(255),@Ppriority varchar(255)

While exists ( select top 1 * from DataWarehouse.Staging.epc_email_log where processed = 0 )
Begin 

select top 1 @Pepc_email_log_id = epc_email_log_id,@PEmailTable = EmailTable,@Ppriority = priority  
from DataWarehouse.Staging.epc_email_log where processed = 0

select @Pepc_email_log_id,@PEmailTable,@Ppriority

exec Datawarehouse.[dbo].[SP_EPC_Email_PreferencePriority] @TableNm = @PEmailTable , @Priority  = @PPriority

update DataWarehouse.Staging.epc_email_log 
set processed = 1
where epc_email_log_id = @Pepc_email_log_id

END



END
GO
