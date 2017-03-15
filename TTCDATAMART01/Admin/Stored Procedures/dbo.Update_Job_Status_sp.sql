SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[Update_Job_Status_sp]
as
declare @name varchar(1000), @enabledstatus int, @cmd varchar(max)
if exists (
select distinct 1
from sys.availability_replicas c  join sys.dm_hadr_availability_group_states b on c.group_id=b.group_id
left join sys.availability_groups a on a.group_id=b.group_id
join sys.dm_hadr_availability_replica_cluster_states d on c.group_id=d.group_id and c.replica_id=d.replica_id
join sys.dm_hadr_availability_replica_states e on d.replica_id=e.replica_id
join sys.dm_hadr_database_replica_cluster_states g on e.replica_id=g.replica_id
join sys.dm_hadr_database_replica_states f on f.replica_id=g.replica_id
and f.group_database_id=g.group_database_id
where g.database_name='admin' and e.role_desc='SECONDARY' and e.synchronization_health_desc='HEALTHY')
begin

	if @@servername=
	(SELECT RCS.replica_server_name FROM sys.availability_groups_cluster AS AGC
	JOIN sys.dm_hadr_availability_replica_cluster_states AS RCS
	ON RCS.group_id = AGC.group_id
	JOIN sys.dm_hadr_availability_replica_states AS ARS
	ON ARS.replica_id = RCS.replica_id
	WHERE ARS.role_desc = 'PRIMARY')
	begin
		if @@servername=(select top 1 servername from sysjobs)
			begin

				/*
				select * from sysjobs
				select * from [dbo].[sysjobs_exception]
				*/

				insert into sysjobs
				select a.name, a.enabled, @@servername from msdb..sysjobs a 
				left join sysjobs b on a.name=b.name
				left join dbo.sysjobs_exception c on a.name=c.name and @@servername=c.servername
				where b.name is null and c.name is null

				update a
				set a.enabled=b.enabled
				from sysjobs a join msdb..sysjobs b on a.name=b.name and a.enabled<>b.enabled

				/*
				select * from sysjobs a join msdb..sysjobs b on a.name=b.name and a.enabled<>b.enabled
				*/

				delete a
				from sysjobs a left join [dbo].[sysjobs_exception] b on 
				a.name=b.name and a.servername=b.servername
				left join msdb..sysjobs c on a.name=c.name
				where b.name is null and c.name is null

				/*
				select * from sysjobs a left join [dbo].[sysjobs_exception] b on 
				a.name=b.name and a.servername=b.servername
				left join msdb..sysjobs c on a.name=c.name
				where b.name is null and c.name is null
				*/

			end

		if @@servername<>(select top 1 servername from sysjobs)
			Begin
			--if failed over, update the job status as the previous primary server job status
			
				declare  updatejob cursor for
				select a.name, a.enabled from sysjobs a left join sysjobs_exception b on a.name=b.name
				and a.servername=b.servername  where b.name is null 

				open updatejob
				fetch next from updatejob into @name,@enabledstatus

				while @@FETCH_STATUS=0
					begin
						update sysjobs
						set servername=@@servername where name=@name
						exec msdb..sp_update_job @job_name=@name, @enabled=@enabledstatus
						fetch next from updatejob into @name,@enabledstatus
					end
				close updatejob
				deallocate updatejob

			end
	end
	--Disabled this section and created Master.[dbo].[DisableJobOnSecondary]
	--else
	--	begin
	--	--If not on primary server, disable all jobs except the jobs in exception table
	--		if exists (select top 1 1 from msdb..sysjobs a left join sysjobs_exception b on a.name=b.name and @@servername=b.servername where b.name is null and a.enabled=1)
	--		begin
	--			declare  disablejob cursor for
	--			select a.name from sysjobs a left join sysjobs_exception b on a.name=b.name
	--			and a.servername=b.servername  where b.name is null 

	--			open disablejob
	--			fetch next from disablejob into @name

	--			while @@FETCH_STATUS=0
	--				begin
	--					exec msdb..sp_update_job @job_name=@name, @enabled=0
	--					fetch next from disablejob into @name
	--				end
	--			close disablejob
	--			deallocate disablejob
	--		end

	--	end
	/*
	insert into [dbo].[sysjobs_exception]
	select 'Sync SQL Jobs',1,'TTCDMCL01'
	union 
	select 'Sync SSIS packages',1,'TTCDMCL01'
	union
	select  'SSIS Server Maintenance Job',1,'TTCDMCL01'
	union
	select 'syspolicy_purge_history',1,'TTCDMCL01'
	union
	select 'Sync SQL Jobs',1,'TTCDMCL02'
	union 
	select 'Sync SSIS packages',1,'TTCDMCL02'
	union
	select  'SSIS Server Maintenance Job',1,'TTCDMCL02'
	union
	select 'syspolicy_purge_history',1,'TTCDMCL02'
	union 
	select 'SQL Job Status Check',1,'TTCDMCL02'
	union
	select 'SQL Job Status Check',1,'TTCDMCL01'
	*/

end


GO
