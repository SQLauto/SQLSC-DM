SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCedure [Staging].[SP_UpsellCourseRankingOnly]
	--@LPType varchar(10) = 'Email',
	@LogicName varchar(20) = 'RankBySales',
	@Months int = 12,
	@Country varchar(5) = 'US',
	@Name varchar(50) = 'Unrecognized'
	--@StartDate date = null,
	--@CampaignExpire date = null,
	--@LPID int = 0,
	--@LoadFinal varchar(1) = 'N',
	--@DeBugCode INT = 1
AS

begin

/* Only for Course ranking used by UPSELL */

/*- Declare variables*/
	DECLARE @StartDate date = null
	DECLARE	@CampaignExpire date = null
    DECLARE @ErrorMsg VARCHAR(400)   /*- Error message for error handling.*/
    DECLARE @MailedAdcode INT
    DECLARE @SQLStatement nvarchar(1000)
    declare @TablePrefix varchar(100),
			@StartDateChar varchar(10),
			@NegMonths int

	set @StartDate = coalesce(@StartDate, getdate())
	set @StartDateChar = CONVERT(varchar,@StartDate,112)
	set @NegMonths = -1 * @Months
	
	set @CampaignExpire = coalesce(@CampaignExpire, dateadd(week,2,getdate()))

    /*- Generate  Final table name.*/
    DECLARE @WebTable VARCHAR(100),
			@WebTable2 VARCHAR(100)

    SELECT 
    	@WebTable = 'lstmgr.dbo.UpsellCourseRank_' + @Country + '_' + @StartDateChar + '_' + @Name + '_CourseRank',
        @WebTable2 = 'UpsellCourseRank_' + @Country + '_' + @StartDateChar + '_' + @Name + '_CourseRank'

 
 
	 --first update the price matrix
	delete from staging.mktpricingmatrix
	where catalogcode = 100

	insert into staging.mktpricingmatrix
	select 100 as Catalogcode, 
		mpm.UserStockItemID, 
		mpm.StockItemID, 
		mpm.UnitPrice, 
		mpm.PageAllocation, 
		mpm.unitcurrency
	from staging.mktpricingmatrix mpm join
		Staging.invitem ii on mpm.userstockitemid = ii.stockitemid
	where catalogcode = 4
	and ii.courseid in (Select distinct CourseID
					from mapping.UpsellCourseRank_InputCourse)

	--check courses in PM
	--select distinct MPM.Catalogcode, II.CourseID, MC.CourseName, MC.SubjectCategory2, BundleFlag
	--FROM staging.mktpricingmatrix mpm left outer join
	--	superstardw.dbo.invitem ii on ii.userstockitemid = mpm.userstockitemid JOIN
	--	Mapping.dmcourse mc on ii.courseid = mc.courseid
	--where mpm.catalogcode in (100)
	--order by 1,2
	
	/* Create Orders table by Country */
	 if object_id('Staging.UpsellCourseRank_Orders') is not null 
       drop table Staging.UpsellCourseRank_Orders
 
	if @Country in ('AU','GB')
		Begin
			select *
			into Staging.UpsellCourseRank_Orders
			from Marketing.DMPurchaseOrders
			where DateOrdered >= DATEADD(month,@NegMonths,GETDATE())
			and BillingCountryCode = @Country
		end
	else
		Begin
			select *
			into Staging.UpsellCourseRank_Orders
			from Marketing.DMPurchaseOrders
			where DateOrdered >= DATEADD(month,@NegMonths,GETDATE())	
		end					

    /*- STEP2: Obtain Sales of courses offered in the catalog by PreferredCategory */
    /*- 	   of the customer FROM customersubjectmatrix table and assign Ranks based on sales*/

    /*- Generate the list of courses and saleprices by PreferredCategory*/
    --IF @DeBugCode = 1 PRINT 'STEP2 BEGIN'
    --IF @DeBugCode = 1 PRINT 'Generate Ranks Table'
    
    declare @BundleCount int
      
    if object_id('Staging.TempUpsellCourseRankCourseRank') is not null drop table Staging.TempUpsellCourseRankCourseRank
    if object_id('Staging.TempUpsellCourseRankBundleCourse') is not null drop table Staging.TempUpsellCourseRankBundleCourse   
    if object_id('Staging.TempUpsellCourseRankBundleCourseByCategory') is not null drop table Staging.TempUpsellCourseRankBundleCourseByCategory
    if object_id('Staging.TempUpsellCourseRank') is not null drop table Staging.TempUpsellCourseRank
    

	
	/*- Assign ranking based on Sales*/
   
	if @LogicName = 'RankBySales'    
	begin      

    SELECT 
    	sum(FNL.SumSales) AS SumSales,
    	sum(fnl.Orders) as TotalOrders,
        FNL.CourseID,
        cast(0 as money) as CourseParts,
        FNL.PreferredCategory,
		convert(float,0.0) as Rank,
     cast(1 as bit) as FlagPurchased,
        cast(0 as bit) as FlagBundle
    INTO Staging.TempUpsellCourseRankCourseRank
    FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
				COUNT(distinct O.OrderID) as Orders,
                II.Courseid AS CourseID,
                'GEN' AS PreferredCategory
        FROM Staging.UpsellCourseRank_Orders O JOIN
            Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
            Staging.InvItem II ON OI.StockItemID = II.StockItemID 
            JOIN Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID	
        WHERE O.SequenceNum > 1
        AND MPM.CatalogCode = 100
        GROUP BY  II.Courseid
        UNION
        SELECT sum(OI.SalesPrice) AS SumSales,	
			COUNT(distinct O.OrderID) as Orders,		
            II.Courseid AS CourseID,
            ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
        FROM 
            Marketing.CampaignCustomerSignature CSM JOIN
                   Staging.UpsellCourseRank_Orders O  ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
                   Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
            Staging.InvItem II ON OI.StockItemID = II.StockItemID 
            JOIN Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID
        WHERE O.SequenceNum > 1
        AND MPM.CatalogCode = 100
        GROUP BY CSM.PREFERREDCATEGORY2, II.Courseid)FNL
    GROUP BY FNL.CourseID,FNL.PreferredCategory
    
    SELECT 
	    BC.BundleID, 
        MC1.CourseName AS BundleName,
        BC.CourseID, 
        MC2.CourseName, 
        MC2.CourseParts, 
        MC2.ReleaseDate,
        cast(0 as money) as Sales
    INTO Staging.TempUpsellCourseRankBundleCourse
    from Mapping.BundleComponents BC (nolock) 
    JOIN
    (
        SELECT DISTINCT BC.BundleID
        FROM Staging.MktPricingMatrix MPM (nolock)
        JOIN Staging.InvItem II (nolock) ON MPM.UserStockItemID = II.StockItemID 
        JOIN Mapping.BundleComponents BC (nolock) ON II.CourseID = BC.BundleID
        WHERE MPM.CatalogCode = 100
    ) B on BC.BundleID = B.BundleID 
    JOIN Mapping.DMcourse MC1 (nolock) ON BC.BundleID = MC1.CourseID 
    JOIN Mapping.DMcourse MC2 (nolock) ON BC.CourseID = MC2.CourseID
    where bc.bundleflag > 0
    
    SELECT @BundleCount = COUNT(BundleID) 
    FROM Staging.TempUpsellCourseRankBundleCourse (nolock)
    
    if @BundleCount > 0
    begin
        SELECT Sum(FNL.SumSales) AS SumSales,
    		sum(fnl.Orders) as TotalOrders,
            FNL.CourseID,
            FNL.PreferredCategory
        INTO Staging.TempUpsellCourseRankBundleCourseByCategory
        FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
					COUNT(distinct O.OrderID) as Orders,
                    BC.CourseID,
                    'GEN' AS PreferredCategory
            FROM  Staging.UpsellCourseRank_Orders O JOIN
                Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
                (SELECT DISTINCT CourseID
                FROM Staging.TempUpsellCourseRankBundleCourse) BC on OI.CourseID = BC.CourseID
            AND O.SequenceNum > 1
            GROUP BY BC.CourseID
            UNION
            SELECT sum(OI.SalesPrice) AS SumSales,
				COUNT(distinct O.OrderID) as Orders,
                BC.CourseID,
                ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
            FROM Marketing.CampaignCustomerSignature CSM JOIN
                Staging.UpsellCourseRank_Orders O ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
                Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
                (SELECT DISTINCT CourseID
                FROM Staging.TempUpsellCourseRankBundleCourse) BC on OI.CourseID = BC.CourseID
            WHERE O.SequenceNum > 1
            GROUP BY BC.CourseID, CSM.PreferredCategory2) FNL
        GROUP BY FNL.CourseID,FNL.PreferredCategory
        
        INSERT INTO Staging.TempUpsellCourseRankCourseRank
        (
        	SumSales,
            CourseID,
            PreferredCategory,
            Rank,
            FlagBundle,
            CourseParts,
            FlagPurchased
       	)
        SELECT 
     	AVG(B.SumSales) SumSales,
            A.BundleID AS CourseID, 
            B.PreferredCategory,
            convert(float,0) AS Rank,
            1 AS FlagBundle,
            0 as CourseParts,
            1
        FROM Staging.TempUpsellCourseRankBundleCourse A (nolock)
        JOIN Staging.TempUpsellCourseRankBundleCourseByCategory B (nolock) ON A.CourseID = B.CourseID
        GROUP BY A.BundleID, B.PreferredCategory
    end
    
  
        /*- If there is no data available for courses under a particular*/
	    /*- preferred category, append courses FROM 'GEN' category.*/
	    
        ;with cteFullCourseSet(CourseID, PreferredCategory) as
        (
            select 
                t.CourseID,
                t2.PreferredCategory        
            from Staging.TempUpsellCourseRankCourseRank t (nolock),
				(select distinct t2.PreferredCategory 
				from Staging.TempUpsellCourseRankCourseRank t2 (nolock) 
				where t2.PreferredCategory <> 'Gen') t2
            where 
                t.PreferredCategory = 'Gen'
        )
        insert into Staging.TempUpsellCourseRankCourseRank
        (
            CourseID,
            PreferredCategory,
            FlagPurchased,
            Rank
        )
        select 
            gc.CourseID,
            gc.PreferredCategory,
            0, 
            CONVERT(float,0.0)
        from cteFullCourseSet gc
        except
        select 
            t.CourseID,
            t.PreferredCategory,
            0,
            CONVERT(float,0.0)
        from Staging.TempUpsellCourseRankCourseRank t (nolock)
        where 
            t.PreferredCategory <> 'Gen'

        update t
        set t.SumSales = t2.SumSales
        from Staging.TempUpsellCourseRankCourseRank t
        join Staging.TempUpsellCourseRankCourseRank t2 (nolock) on t.CourseID = t2.CourseID
        where
            t.FlagPurchased = 0
            and t2.PreferredCategory = 'Gen'
            
        
        ;with cteRank(CourseID, PreferredCategory, RankNum) as    
        (
            select 
                t.CourseID, 
                t.PreferredCategory,
                row_number() over(partition by t.PreferredCategory order by t.FlagPurchased desc, t.SumSales desc)
            from Staging.TempUpsellCourseRankCourseRank t (nolock)
        )
        update t
        set t.Rank = convert(float,r.RankNum)
        from Staging.TempUpsellCourseRankCourseRank t
        join cteRank r on r.CourseID = t.CourseID and r.PreferredCategory = t.PreferredCategory

        print 'end or rankbysales'
        
    end
    


	/*- Assign ranking based on Orders*/
   
	if @LogicName = 'RankByOrders'    
	begin      

    SELECT 
    	sum(FNL.SumSales) AS SumSales,
    	sum(fnl.Orders) as TotalOrders,
        FNL.CourseID,
        cast(0 as money) as CourseParts,
        FNL.PreferredCategory,
		convert(float,0.0) as Rank,
        cast(1 as bit) as FlagPurchased,
        cast(0 as bit) as FlagBundle
    INTO Staging.TempUpsellCourseRankCourseRank
    FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
				COUNT(distinct O.OrderID) as Orders,
                II.Courseid AS CourseID,
                'GEN' AS PreferredCategory
        FROM Staging.UpsellCourseRank_Orders O JOIN
            Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
            Staging.InvItem II ON OI.StockItemID = II.StockItemID 
            JOIN Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID	
        WHERE O.SequenceNum = 1
        AND MPM.CatalogCode = 100
        GROUP BY  II.Courseid
        UNION
        SELECT sum(OI.SalesPrice) AS SumSales,	
			COUNT(distinct O.OrderID) as Orders,		
          II.Courseid AS CourseID,
            ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
        FROM 
            Marketing.CampaignCustomerSignature CSM JOIN
                   Staging.UpsellCourseRank_Orders O  ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
                   Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
            Staging.InvItem II ON OI.StockItemID = II.StockItemID 
            JOIN Staging.MktPricingMatrix MPM ON MPM.UserStockItemID = II.StockItemID
        WHERE O.SequenceNum = 1
        AND MPM.CatalogCode = 100
        GROUP BY CSM.PREFERREDCATEGORY2, II.Courseid)FNL
    GROUP BY FNL.CourseID,FNL.PreferredCategory
    
    SELECT 
	    BC.BundleID, 
        MC1.CourseName AS BundleName,
        BC.CourseID, 
        MC2.CourseName, 
        MC2.CourseParts, 
        MC2.ReleaseDate,
        cast(0 as money) as Sales
    INTO Staging.TempUpsellCourseRankBundleCourse
    from Mapping.BundleComponents BC (nolock) 
    JOIN
    (
        SELECT DISTINCT BC.BundleID
        FROM Staging.MktPricingMatrix MPM (nolock)
        JOIN Staging.InvItem II (nolock) ON MPM.UserStockItemID = II.StockItemID 
        JOIN Mapping.BundleComponents BC (nolock) ON II.CourseID = BC.BundleID
        WHERE MPM.CatalogCode = 100
    ) B on BC.BundleID = B.BundleID 
    JOIN Mapping.DMcourse MC1 (nolock) ON BC.BundleID = MC1.CourseID 
    JOIN Mapping.DMcourse MC2 (nolock) ON BC.CourseID = MC2.CourseID
    where bc.bundleflag > 0
    
    SELECT @BundleCount = COUNT(BundleID) 
    FROM Staging.TempUpsellCourseRankBundleCourse (nolock)
    
    if @BundleCount > 0
    begin
        SELECT Sum(FNL.SumSales) AS SumSales,
    		sum(fnl.Orders) as TotalOrders,
            FNL.CourseID,
            FNL.PreferredCategory
        INTO Staging.TempUpsellCourseRankBundleCourseByCategory
        FROM	(SELECT sum(OI.SalesPrice) AS SumSales,
					COUNT(distinct O.OrderID) as Orders,
                    BC.CourseID,
                    'GEN' AS PreferredCategory
            FROM  Staging.UpsellCourseRank_Orders O JOIN
                Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
                (SELECT DISTINCT CourseID
                FROM Staging.TempUpsellCourseRankBundleCourse) BC on OI.CourseID = BC.CourseID
            AND O.SequenceNum = 1
            GROUP BY BC.CourseID
            UNION
            SELECT sum(OI.SalesPrice) AS SumSales,
				COUNT(distinct O.OrderID) as Orders,
                BC.CourseID,
                ISNULL(CSM.PreferredCategory2,'GEN') AS PreferredCategory
            FROM Marketing.CampaignCustomerSignature CSM JOIN
                Staging.UpsellCourseRank_Orders O ON CSM.CUSTOMERID = O.CUSTOMERID JOIN
                Marketing.DMPurchaseOrderItems OI ON O.ORDERID = OI.ORDERID JOIN
                (SELECT DISTINCT CourseID
                FROM Staging.TempUpsellCourseRankBundleCourse) BC on OI.CourseID = BC.CourseID
            WHERE O.SequenceNum = 1
            GROUP BY BC.CourseID, CSM.PreferredCategory2) FNL
        GROUP BY FNL.CourseID,FNL.PreferredCategory
        
        INSERT INTO Staging.TempUpsellCourseRankCourseRank
        (
        	SumSales,
            CourseID,
            PreferredCategory,
            Rank,
            FlagBundle,
            CourseParts,
            FlagPurchased
       	)
        SELECT 
        	AVG(B.SumSales) SumSales,
            A.BundleID AS CourseID, 
            B.PreferredCategory,
            convert(float,0) AS Rank,
            1 AS FlagBundle,
            0 as CourseParts,
            1
        FROM Staging.TempUpsellCourseRankBundleCourse A (nolock)
        JOIN Staging.TempUpsellCourseRankBundleCourseByCategory B (nolock) ON A.CourseID = B.CourseID
        GROUP BY A.BundleID, B.PreferredCategory
    end
    
  
        /*- If there is no data available for courses under a particular*/
	    /*- preferred category, append courses FROM 'GEN' category.*/
	    
        ;with cteFullCourseSet(CourseID, PreferredCategory) as
        (
            select 
                t.CourseID,
                t2.PreferredCategory        
            from Staging.TempUpsellCourseRankCourseRank t (nolock),
				(select distinct t2.PreferredCategory 
				from Staging.TempUpsellCourseRankCourseRank t2 (nolock) 
				where t2.PreferredCategory <> 'Gen') t2
            where 
                t.PreferredCategory = 'Gen'
  )
        insert into Staging.TempUpsellCourseRankCourseRank
        (
            CourseID,
            PreferredCategory,
            FlagPurchased,
            Rank
        )
        select 
            gc.CourseID,
            gc.PreferredCategory,
            0, 
            CONVERT(float,0.0)
        from cteFullCourseSet gc
        except
        select 
            t.CourseID,
            t.PreferredCategory,
            0,
            CONVERT(float,0.0)
        from Staging.TempUpsellCourseRankCourseRank t (nolock)
        where 
            t.PreferredCategory <> 'Gen'

        update t
        set t.TotalOrders = t2.TotalOrders
        from Staging.TempUpsellCourseRankCourseRank t
        join Staging.TempUpsellCourseRankCourseRank t2 (nolock) on t.CourseID = t2.CourseID
        where
            t.FlagPurchased = 0
            and t2.PreferredCategory = 'Gen'
            
        
        ;with cteRank(CourseID, PreferredCategory, RankNum) as    
        (
            select 
                t.CourseID, 
                t.PreferredCategory,
                row_number() over(partition by t.PreferredCategory order by t.FlagPurchased desc, t.TotalOrders desc)
            from Staging.TempUpsellCourseRankCourseRank t (nolock)
        )
        update t
        set t.Rank = convert(float,r.RankNum)
        from Staging.TempUpsellCourseRankCourseRank t
        join cteRank r on r.CourseID = t.CourseID and r.PreferredCategory = t.PreferredCategory
        
        print 'end or RankByOrders'
        
    end  
    
    	/*- Assign ranking based on Pre Rank */
	if @LogicName = 'PreRank'
		begin
			SELECT 
        		CONVERT(money,0.0) as SumSales,
        		0 as TotalOrders,
				CourseID, 
				convert(varchar(5),'GEN') as PreferredCategory,
				Rank,
				0 as FlagBundle,
				convert(money,0) as CourseParts,
				1 as FlagPurchased
			into Staging.TempUpsellCourseRankCourseRank			
			FROM mapping.UpsellCourseRank_InputCourse
		end

	if @LogicName <> 'PreRank'
		begin
			/* If Ranks are higher than 15, then float them up*/
			--IF @DeBugCode = 1 PRINT 'If Ranks are higher than 15 for Bundles, then float them up'
			
			UPDATE ECR
			SET ECR.Rank = ECR.Rank/3.21
			FROM Staging.TempUpsellCourseRankCourseRank ECR JOIN
				Mapping.DMCourse MC ON ECR.CourseID = MC.CourseID
			WHERE RANK > 15
			AND mc.Bundleflag = 1
		end			
		
 
	--SELECT a.Sumsales, a.TotalOrders, a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
	--FROM Staging.TempUpsellCourseRankCourseRank a,
	--	Mapping.DMCourse b
	--WHERE a.CourseID = b.CourseID
	--ORDER BY a.PreferredCategory, a.Rank   
      

	-----float courses higher..
	--UPDATE Staging.TempUpsellCourseRankCourseRank
	--SET Rank = rank/12.6
	--where courseid in (3390,3130,3356,3480,3372,3410,3180,893,323,2390,2752,2997,2429,2598,2567,297,8190,4617,8313,8467,8593,8570,877,4812,7237,790)

    /*- Report1: Ranking check report*/
 --   PRINT 'Ranking QC Report'

	--SELECT a.Sumsales, a.TotalOrders, a.CourseID,b.CourseName,a.PreferredCategory, a.Rank   
	--FROM Staging.TempUpsellCourseRankCourseRank a,
	--	Mapping.DMCourse b
	--WHERE a.CourseID = b.CourseID
	--ORDER BY a.PreferredCategory, a.Rank  
	
	/* Now, clean up the ranking table. */
	--declare @PrefID int
	
	--update Mapping.UpsellCourseRank_PrefID
	--set Prefid = PrefID + 1
	
	--select @PrefID = PrefID from Mapping.UpsellCourseRank_PrefID
	
	--set @PrefID = @LPID  -- gives control to Sri
	

	update Staging.TempUpsellCourseRankCourseRank
	set preferredcategory = replace(preferredcategory, ' ','')

	/*
	select * from Staging.TempUpsellCourseRankCourseRank
	order by RANK
	*/
		 
	select *,
		@CampaignExpire as CampaignExpireDate,
		CONVERT(tinyint,0) blnMarkdown,
		CONVERT(Varchar(100), null) Message 
	into Staging.TempUpsellCourseRank		
	from  Staging.TempUpsellCourseRankCourseRank
	 
	/* Now, load the final table into lstmgr table */
    
    print 'Final Table is:'
    print '==============='
    print @WebTable
    
      if object_id(@WebTable) is not null 
    begin
        set @SQLStatement = 'drop table ' + @WebTable
        print (@SQLStatement)
        exec sp_executesql @SQLStatement
    end
    
    set @SQLStatement = 'select * into ' + @WebTable + ' from Staging.TempUpsellCourseRank (nolock) order by rank'
    print (@SQLStatement)
    exec sp_executesql @SQLStatement
     
	Truncate table datawarehouse.Mapping.UpsellCourseRank_US_Unrecognized_CourseRank

	Insert into datawarehouse.Mapping.UpsellCourseRank_US_Unrecognized_CourseRank
	select * from Staging.TempUpsellCourseRank (nolock) 
	order by  5,6
		
    print 'Final Table is:'
    print '==============='
    print @WebTable		
		
    if object_id('Staging.TempUpsellCourseRankCourseRank') is not null drop table Staging.TempUpsellCourseRankCourseRank
    if object_id('Staging.TempUpsellCourseRankBundleCourse') is not null drop table Staging.TempUpsellCourseRankBundleCourse   
    if object_id('Staging.TempUpsellCourseRankBundleCourseByCategory') is not null drop table Staging.TempUpsellCourseRankBundleCourseByCategory
    if object_id('Staging.TempUpsellCourseRank') is not null drop table Staging.TempUpsellCourseRank
    


Print 'Final table Name'

Print @WebTable
     
end
GO
