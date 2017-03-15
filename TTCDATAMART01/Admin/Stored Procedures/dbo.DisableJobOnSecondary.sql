SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[DisableJobOnSecondary] as
declare @name varchar(1000), @enabledstatus int, @cmd varchar(max)
if  exists (
select distinct 1
from sys.availability_replicas c  join sys.dm_hadr_availability_group_states b on c.group_id=b.group_id
left join sys.availability_groups a on a.group_id=b.group_id
join sys.dm_hadr_availability_replica_cluster_states d on c.group_id=d.group_id and c.replica_id=d.replica_id
join sys.dm_hadr_availability_replica_states e on d.replica_id=e.replica_id
join sys.dm_hadr_database_replica_cluster_states g on e.replica_id=g.replica_id
join sys.dm_hadr_database_replica_states f on f.replica_id=g.replica_id
and f.group_database_id=g.group_database_id
where g.database_name='admin' and e.role_desc='SECONDARY' and e.synchronization_health_desc='HEALTHY')
Begin
	if @@servername=
	(SELECT RCS.replica_server_name FROM sys.availability_groups_cluster AS AGC
	JOIN sys.dm_hadr_availability_replica_cluster_states AS RCS
	ON RCS.group_id = AGC.group_id
	JOIN sys.dm_hadr_availability_replica_states AS ARS
	ON ARS.replica_id = RCS.replica_id
	WHERE ARS.role_desc = 'SECONDARY')

	
	begin
		--If not on primary server, disable all jobs except the jobs in exception table
			if exists (select top 1 1 from msdb..sysjobs a left join TTCDMCL02.admin.dbo.sysjobs_exception b 
			on a.name=b.name and @@servername=b.servername where b.name is null and a.enabled=1)
			begin
				declare  disablejob cursor for
				select a.name from TTCDMCL02.admin.dbo.sysjobs a left join TTCDMCL02.admin.dbo.sysjobs_exception b on a.name=b.name
				and a.servername=b.servername  where b.name is null 

				open disablejob
				fetch next from disablejob into @name

				while @@FETCH_STATUS=0
					begin
						exec msdb..sp_update_job @job_name=@name, @enabled=0
						fetch next from disablejob into @name
					end
				close disablejob
				deallocate disablejob
			end

		end

End
GO
