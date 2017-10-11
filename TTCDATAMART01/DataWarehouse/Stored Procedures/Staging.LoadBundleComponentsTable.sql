SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadBundleComponentsTable] 
AS
	-- Preethi Ramanujam    8/22/2017 - Load bundle components From Magento Table
begin

    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'TempBundleComponents')
        truncate TABLE  staging.TempBundleComponents


	declare @counter int
	set @counter = 1
	-- drop table staging.TempBundleComponents
	--truncate table staging.TempBundleComponents

	while @counter <= 14
	begin
		insert into staging.TempBundleComponents
		select
			a.course_id as BundleID,
			b.CourseName as BundleName,
			b.CourseParts as BundleParts,
			DataWarehouse.dbo.Wordparser(a.set_course_ids,@counter,',') CourseID,
			c.CourseName,
			c.CourseParts,
			convert(money,null) Total,
			convert(float,null) Portion
		--into staging.TempBundleComponents
		from Imports.Magento.Sets a left join
			datawarehouse.Mapping.DMcourse b on a.course_id = b.CourseID left join
			datawarehouse.Mapping.DMcourse c on DataWarehouse.dbo.Wordparser(a.set_course_ids,@counter,',') = c.CourseID 
		where DataWarehouse.dbo.Wordparser(a.set_course_ids,@counter,',') is not null 
		and a.course_id in (SELECT DISTINCT II.COURSEID
						FROM 	Superstardw..INVITEM II LEFT OUTER JOIN datawarehouse.mapping.bundlecomponents DMBC 								
												ON II.COURSEID = DMBC.BUNDLEID 	JOIN
							daximports..load_MktCourse mc on mc.courseid = ii.courseid								
						WHERE II.ITEMCATEGORYID LIKE 'BUNDLE' 
						AND DMBC.BUNDLEID IS NULL 
						AND II.InvStatusID = 'Active'
						and ii.CourseID not in (570,1369,6100,8509,9275,1940))
			--and c.ReleaseDate <= dateadd(month,1,getdate())

		set @counter = @counter + 1

	end

	update a
	set a.Total = b.total
	from staging.TempBundleComponents a join
		(select BundleID, sum(courseparts) Total
		from staging.TempBundleComponents
		group by BundleID)b on a.BundleID = b.BundleID

	update Staging.TempBundleComponents
	set Portion = CourseParts/Total

	select * from staging.TempBundleComponents
	order by 1,4



	--insert into Mapping.BundleComponents
	--select BundleID
	--	,CourseID
	--	,Portion
	--	,1 as BundleFlag 
	--from staging.TempBundleComponents


end
GO
