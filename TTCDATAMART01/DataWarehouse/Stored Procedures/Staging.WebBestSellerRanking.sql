SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[WebBestSellerRanking]
AS
	-- PR 5/29/2014 To generate BestSeller Ranking for Magento platform
begin
	
	--------------------------------------------------------------------------------------
	-- US Prospects
	--------------------------------------------------------------------------------------
		
	-- Get valid course list
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Temp_BSR_CourseList')
	drop table Staging.Temp_BSR_CourseList

	SELECT a.*
	INTO Staging.Temp_BSR_CourseList
	FROM Mapping.DMCourse a JOIN
		(SELECT DISTINCT CourseID 
		FROM Staging.Invitem 
		WHERE forsaleonweb=1 
		AND forsaletoconsumer=1 
		AND InvStatusID in ('Active','Disc')
		AND itemcategoryid in ('course','Bunlde'))B ON A.CourseID = B.courseID
	WHERE A.BundleFlag = 0
	UNION
	SELECT *
	FROM Mapping.DMCourse 
	WHERE CourseID = 6100
	ORDER BY 1

	CREATE INDEX IX_Temp_BSR_CourseList on Staging.Temp_BSR_CourseList(CourseID)


	-- For Prospecting Web: Need ranking based on Orders from 1st order
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Temp_BSR_CourseSalesOrders')
	drop table Staging.Temp_BSR_CourseSalesOrders

	SELECT Sum(FNL.SumSales) AS SumSales, Sum(TotalOrders) TotalOrders,
		FNL.CourseID,
		FNL.CourseName,
		FNL.Parts,
		FNL.ReleaseDate,
		fnl.FlagNew,
		fnl.Website
	INTO Staging.Temp_BSR_CourseSalesOrders
	FROM (SELECT sum(OI.SalesPrice) AS SumSales, 
			Count(distinct oi.orderid) TotalOrders,
			OI.Courseid AS CourseID, 
			OI.CourseName, OI.Parts, MPM.ReleaseDate,
			case when o.SequenceNum = 1 then 1 else 0 end as FlagNew,
			case when o.CurrencyCode like '%US%' then 'US'
				when o.CurrencyCode = 'GBP' then 'UK'
				when o.CurrencyCode = 'AUD' then 'AU'
				else 'US'
			end as Website
		FROM Datawarehouse.Marketing.DMPurchaseOrders O  
			JOIN Datawarehouse.Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID 
			JOIN Staging.Temp_BSR_CourseList MPM ON MPM.CourseID = OI.CourseID
		WHERE O.DATEORDERED BETWEEN DATEADD(Month,-12,GETDATE()) AND GETDATE()
		GROUP BY OI.Courseid, OI.CourseName, OI.Parts, MPM.ReleaseDate,
				case when o.SequenceNum = 1 then 1 else 0 end,
			case when o.CurrencyCode like '%US%' then 'US'
				when o.CurrencyCode = 'GBP' then 'UK'
				when o.CurrencyCode = 'AUD' then 'AU'
				else 'US'
			end)FNL
	GROUP BY FNL.CourseID, FNL.CourseName, Fnl.Parts, FNL.ReleaseDate, fnl.FlagNew, fnl.Website
	ORDER BY fnl.Website, fnl.Flagnew, Sum(TotalOrders) DESC

select website, flagnew, COUNT(courseid)
from Staging.Temp_BSR_CourseSalesOrders
group by Website, flagnew
order by 1,2

	-- add missing courses to the bottom of the list
	insert into Staging.Temp_BSR_CourseSalesOrders
	select 0, 0 , a.CourseID, a.CourseName, a.CourseParts, a.ReleaseDate, 1 as FlagNew, 'US' Website
	from Staging.Temp_BSR_CourseList a left outer join
		(select * 
		from Staging.Temp_BSR_CourseSalesOrders
		where FlagNew = 1 and Website = 'US') b on a.courseid = b.courseid
	where b.courseid is null
	union
	select 0, 0 , a.CourseID, a.CourseName, a.CourseParts, a.ReleaseDate,  0 as FlagNew, 'US' Website
	from Staging.Temp_BSR_CourseList a left outer join
		(select * 
		from Staging.Temp_BSR_CourseSalesOrders
		where FlagNew = 0 and Website = 'US') b on a.courseid = b.courseid
	where b.courseid is null
	union
	select 0, 0 , a.CourseID, a.CourseName, a.CourseParts, a.ReleaseDate, 1 as FlagNew, 'UK' Website
	from Staging.Temp_BSR_CourseList a left outer join
		(select * 
		from Staging.Temp_BSR_CourseSalesOrders
		where FlagNew = 1 and Website = 'UK') b on a.courseid = b.courseid
	where b.courseid is null
	union
	select 0, 0 , a.CourseID, a.CourseName, a.CourseParts, a.ReleaseDate, 0 as FlagNew, 'UK' Website
	from Staging.Temp_BSR_CourseList a left outer join
		(select * 
		from Staging.Temp_BSR_CourseSalesOrders
		where FlagNew = 0 and Website = 'UK') b on a.courseid = b.courseid
	where b.courseid is null
	union
	select 0, 0 , a.CourseID, a.CourseName, a.CourseParts, a.ReleaseDate, 1 as FlagNew, 'AU' as Website
	from Staging.Temp_BSR_CourseList a left outer join
		(select * 
		from Staging.Temp_BSR_CourseSalesOrders
		where FlagNew = 1 and Website = 'AU') b on a.courseid = b.courseid
	where b.courseid is null
	union
	select 0, 0 , a.CourseID, a.CourseName, a.CourseParts, a.ReleaseDate, 0 as FlagNew, 'AU' Website
	from Staging.Temp_BSR_CourseList a left outer join
		(select * 
		from Staging.Temp_BSR_CourseSalesOrders
		where FlagNew = 0 and Website = 'AU') b on a.courseid = b.courseid
	where b.courseid is null
	
	
	-----------------------------------------------------------------------------
	-- add this under tab: US_RankBySales_OSW and sort by TotalOrders Desc
	-- then calculate Order/month and rerank based on that and that will be
	-- the final ranking for Prospecting.
	-----------------------------------------------------------------------------
	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Temp_BSR_PrspctRank')
	drop table Staging.Temp_BSR_PrspctRank
	
	-- This is the final web ranking for prospecting US
	SELECT a.Sumsales, a.TotalOrders, 
		a.CourseID, b.CourseName, a.Parts, a.ReleaseDate, 
		case when datediff(month,releasedate,getdate()) >= 12 then 12
			when datediff(month, releasedate, getdate()) = 0 then 1
			else datediff(month,releasedate,getdate()) 
		end MonthsSinceRelease, 
		a.Website,
		convert(money,0) as OrdersPerMonth
	into Staging.Temp_BSR_PrspctRank	  
	FROM Staging.Temp_BSR_CourseSalesOrders a join
		SuperStarDW.dbo.MktCourse b on a.CourseID = b.CourseID
	where a.FlagNew = 1		
	ORDER BY WEbsite, a.TotalOrders desc, a.parts desc

	update Staging.Temp_BSR_PrspctRank
	set orderspermonth = totalorders/monthsSinceRelease


	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Temp_BSR_PrspctRankFnl')
	drop table Staging.Temp_BSR_PrspctRankFnl
	
	select *, 
	rank() over(partition by WebSite order by OrdersPerMonth desc, SumSales desc, Parts desc, courseid) as RankFnl
	into Staging.Temp_BSR_PrspctRankFnl
    from Staging.Temp_BSR_PrspctRank
    
   
    Truncate table staging.WebBestSellerRank
    
    insert into staging.WebBestSellerRank
	select CourseID as course_id, 
		RankFnl as guest_bestsellers_rank, 
		0 as authenticated_bestsellers_rank, 
		website
	from staging.Temp_BSR_PrspctRankFnl
	

	-----------------------------------------------------------------------------
	-- US House Web
	-----------------------------------------------------------------------------
	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Temp_BSR_HouseRank')
	drop table Staging.Temp_BSR_HouseRank
	
	SELECT a.Sumsales,a.TotalOrders, a.CourseID, b.CourseName,a.Parts, 
		a.ReleaseDate,
		--case when datediff(week,releasedate,getdate()) >= 52 then 52
		--	when datediff(week,releasedate,getdate()) <= 8 then (datediff(week,releasedate,getdate()) * 2)
		--	else datediff(week,releasedate,getdate()) 
		--end WeeksSinceRelease, 
		case when datediff(month,releasedate,getdate()) >= 12 then 12
			when datediff(month, releasedate, getdate()) in (0,1,2,3) then 6
			else datediff(month,releasedate,getdate()) 
		end MonthsSinceRelease, 		
		a.WebSite,
		convert(money,0) as SalesPerWeek
	into Staging.Temp_BSR_HouseRank		
	FROM Staging.Temp_BSR_CourseSalesOrders a join
		SuperStarDW.dbo.MktCourse b on a.CourseID = b.CourseID	where a.Flagnew = 0	ORDER BY a.Sumsales desc, a.parts desc	

	--update Staging.Temp_BSR_HouseRank
	----set salesperweek = sumsales/weekssincerelease
	--set salesperweek = sumsales/MonthsSinceRelease


	IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Temp_BSR_HouseRankFnl')
	drop table Staging.Temp_BSR_HouseRankFnl
	
	select *, 
	rank() over(Partition by WebSite order by salesperweek desc, SumSales desc, Parts desc, totalOrders desc, courseid) as RankFnl
	into Staging.Temp_BSR_HouseRankFnl
    from Staging.Temp_BSR_HouseRank
    
    update a
    set a.authenticated_bestsellers_rank = b.RankFnl
    from staging.WebBestSellerRank a join
		staging.Temp_BSR_HouseRankFnl b on a.Course_ID = b.CourseID
											and a.Website = b.WebSite

	
	-- Based on new Magento Request, Change the website/store names and include defaut set that will be for US
	insert into staging.WebBestSellerRank
	select course_id, 
		guest_bestsellers_rank, 
		authenticated_bestsellers_rank, 
		'default' AS website 
	from staging.WebBestSellerRank
	where website = 'US'
	
	
	update staging.WebBestSellerRank
	set Website = case when website = 'AU' then 'au_en'
						when website = 'UK' then 'uk_en'
						when website = 'US' then ''
						else website
					end

	truncate table MagentoExports..WebBestSellerRank
	insert into MagentoExports..WebBestSellerRank
	select *, getdate() from staging.WebBestSellerRank
	
	drop table staging.Temp_BSR_CourseList
	drop table staging.Temp_BSR_CourseSalesOrders
	drop table staging.Temp_BSR_PrspctRank
	drop table staging.Temp_BSR_PrspctRankFnl
	drop table Staging.Temp_BSR_HouseRank
	drop table Staging.Temp_BSR_HouseRankFnl
		
end
GO
