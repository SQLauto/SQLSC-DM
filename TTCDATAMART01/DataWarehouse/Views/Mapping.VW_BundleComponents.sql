SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [Mapping].[VW_BundleComponents]
as
		with bundleInfo (BundleID, BundleName, BundleParts,
						CourseID, CourseName, CourseParts,
						CoursePortion, FlagActiveCourse)
		as
		(
		select distinct i.courseid as BundleID 
			,dmc.CourseName as BundleName
			,dmc.CourseParts as BundleParts
			,i2.courseid as CourseID
			,dmc2.CourseName
			,dmc2.CourseParts
			,case when isnull(dmc.courseparts,0) = 0 then null
				else dmc2.CourseParts/dmc.CourseParts 
			end as CoursePortion
			,dmc2.FlagActive as FlagActiveCourse
		from superstardw..invitemparts ip
		join staging.InvItem i2 
			on ip.partUserStockItemID = i2.StockItemID
		join staging.invitem i
			on ip.UserStockItemID = i.StockItemID
		left join Mapping.DMCourse dmc2 on dmc2.CourseID = i2.CourseID
		left join Mapping.DMCourse dmc on dmc.CourseID = i.CourseID
		where ip.UserStockItemID in 
		-- pull all bundles
		(
		select StockItemID from staging.invitem
		where itemcategoryid = 'bundle' 
		--and courseid not in 
		--(select distinct bundleid from DataWarehouse.Mapping.BundleComponents)
		)
		-- only use those bundles that are made up of courses (not 
		-- marketing-type repackaging of course parts, as sometimes is set up)
		and i2.itemcategoryid = 'course'
		)
		select *
			,ROW_NUMBER() over (partition by BundleID Order by CourseID) as CourseNum
		from bundleInfo


GO
