SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CampaignEmail_ExecuteSharedLogic]
	@LogicName varchar(100),
    @AdCodeActive int = 0,
    @StartDate date = null,
    @TablePrefix varchar(100) = null,
    @NumCourses int = 25
AS
	declare 
    @SQLStatement nvarchar(300)
BEGIN
	--set nocount on
    
	if @LogicName = 'RankBySales'    
	begin    
        /*- If there is no data available for courses under a particular*/
	    /*- preferred category, append courses FROM 'GEN' category.*/
	    
	    PRINT 'In CampaignEmail_ExecuteSharedLogic RankBySales'
	    
	                print 'begin of rank by sales'
            exec sp_help 'Staging.TempECampaignCourseRank'

        ;with cteFullCourseSet(CourseID, PreferredCategory) as
        (
            select 
                t.CourseID,
                t2.PreferredCategory        
            from Staging.TempECampaignCourseRank t (nolock),
            (select distinct t2.PreferredCategory from Staging.TempECampaignCourseRank t2 (nolock) where t2.PreferredCategory <> 'Gen') t2
            where 
                t.PreferredCategory = 'Gen'
        )
        insert into Staging.TempECampaignCourseRank
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
        from Staging.TempECampaignCourseRank t (nolock)
        where 
            t.PreferredCategory <> 'Gen'

        update t
        set t.SumSales = t2.SumSales
        from Staging.TempECampaignCourseRank t
        join Staging.TempECampaignCourseRank t2 (nolock) on t.CourseID = t2.CourseID
        where
            t.FlagPurchased = 0
            and t2.PreferredCategory = 'Gen'
            
            
            print 'middle of rank by sales'
            exec sp_help 'Staging.TempECampaignCourseRank'
        
        ;with cteRank(CourseID, PreferredCategory, RankNum) as    
        (
            select 
                t.CourseID, 
                t.PreferredCategory,
                row_number() over(partition by t.PreferredCategory order by t.FlagPurchased desc, t.SumSales desc)
            from Staging.TempECampaignCourseRank t (nolock)
        )
        update t
        set t.Rank = convert(float,r.RankNum)
        from Staging.TempECampaignCourseRank t
        join cteRank r on r.CourseID = t.CourseID and r.PreferredCategory = t.PreferredCategory
        
        print 'end or rankbysales'
        exec sp_help 'Staging.TempECampaignCourseRank'
        
    end

	if @LogicName = 'DeleteDupEmails'    
	begin    
        DECLARE @RowCount INT
        SET @RowCount =1
        
	    PRINT 'In CampaignEmail_ExecuteSharedLogic DeleteDupEmails'        

        WHILE @RowCount > 0
        BEGIN
        DELETE FROM Staging.TempECampaignEmailableCustomers 
        WHERE CustomerID IN (
                SELECT MIN(Customerid)
                FROM Staging.TempECampaignEmailableCustomers 
                WHERE EmailAddress IN
                        (SELECT EmailAddress
                        FROM Staging.TempECampaignEmailableCustomers
                        GROUP BY EmailAddress
                        HAVING COUNT(Customerid) > 1)
                GROUP BY EmailAddress)
        SET @RowCount = @@ROWCOUNT
        SELECT @RowCount
        END
    end

	if @LogicName = 'LoadCustomerCourseRank'    
	begin   

	    PRINT 'In CampaignEmail_ExecuteSharedLogic LoadCustomerCourseRank'
	    	 
        SELECT 
            a.CustomerID,
            er.CourseID,
            er.Rank as OriginalRank,
            convert(float,0.0) as FinalRank
        INTO Staging.TempECampaignCustomerCourseRank
        FROM Staging.TempECampaignEmailableCustomers a
        join Staging.TempECampaignCourseRank er on ISNULL(a.PreferredCategory,'GEN') = er.PreferredCategory

        -- remove purchased courses
        DELETE a
        FROM Staging.TempECampaignCustomerCourseRank a,
            (SELECT DISTINCT o.customerid, courseid
            FROM marketing.dmpurchaseorderitems oi
            join marketing.dmpurchaseorders o on o.OrderID = oi.OrderID
            WHERE stockitemid LIKE '[PD][ACDMV]%'
            AND courseid IN (SELECT DISTINCT courseid FROM Staging.TempECampaignCourseRank))b
        WHERE a.customerid=b.customerid
        AND a.courseid=b.courseid
	end
    
	if @LogicName = 'ReRankCourses'    
	begin  
	
		PRINT 'In CampaignEmail_ExecuteSharedLogic ReRankCourses'
		  
        ;with cteFinalRank(CourseID, CustomerID, FinalRank) as
        (
            select 
                t.CourseID,
                t.CustomerID,
                rank() over (partition by t.CustomerID order by t.OriginalRank) as FinalRank
            from Staging.TempECampaignCustomerCourseRank t (nolock)
        )
        update t
        set t.FinalRank = convert(float,cte.FinalRank)
        from Staging.TempECampaignCustomerCourseRank t
        join cteFinalRank cte on t.CourseID = cte.CourseID and t.CustomerID = cte.CustomerID
        where cte.FinalRank <= @NumCourses
    	
        -- keep top 25 courses    
        delete t
        from Staging.TempECampaignCustomerCourseRank t
        where t.FinalRank = 0

        -- delete customers having less than 5 courses to offer
        if @NumCourses >= 10
        begin
			DELETE FROM Staging.TempECampaignCustomerCourseRank
			WHERE CustomerID IN 
			(
				SELECT CustomerID
				FROM Staging.TempECampaignCustomerCourseRank t (nolock)
				GROUP BY t.CustomerID
				HAVING COUNT(t.CustomerID) < 5
			)
        end
	end
    
   	if @LogicName = 'AddPreTestData'
	begin    
	
		PRINT 'In CampaignEmail_ExecuteSharedLogic AddPreTestData'
		
        insert into Staging.TempECampaignCustomerCourseRank
        (
            CustomerID,
            CourseID,
            OriginalRank,
            FinalRank
        )
        select distinct
            -1,
            t.CourseID,
            t.CourseID,        
            t.CourseID
        from Staging.TempECampaignCustomerCourseRank t (nolock)
        
        insert into Staging.TempECampaignEmailableCustomers
        (
            AdCode,
            MailedAdcode,
            SubjectLine,
            ECampaignID,
            CustomerID, 
            LastName, 
            FirstName,
            EMailAddress, 
            PreferredCategory, 
            ComboID 
        )
        select top 1 
            @AdcodeActive,
            t.MailedAdcode,
            t.SubjectLine,
            t.ECampaignID,
            -1, 
            'All Courses',
            'Testing', 
            '~DLemailtesters@teachco.com', 
            'GEN', 
            ''
        from Staging.TempECampaignEmailableCustomers (nolock) t
    end
    
   	if @LogicName = 'LoadEmailTemplate'
	begin  
	
		declare @DeadlineDate varchar(50),
				@StopDate datetime
		
		If @StartDate is null set @StartDate = '1/1/2013'
		
		If @AdCodeActive is null set @DeadlineDate = 'weekday, Month dd'
		else 
			begin
				select @StopDate = stopdate
				from DataWarehouse.Mapping.vwAdcodesAll
				where AdCode = @AdcodeActive

				select @DeadlineDate = datename(WEEKDAY,@StopDate) + ', ' + datename(month, @StopDate) + ' ' + convert(varchar,DATEPART(day, @StopDate))
			end				

	
		PRINT 'In CampaignEmail_ExecuteSharedLogic LoadEmailTemplate'
		  
        ;with cteHTML(CustomerID, CustHTML) as
        (
            select 
                t.CustomerID,
                ( 
                    select 
                        '##HDL' + cast(t2.CourseID as varchar(4)) + '## '
                    from Staging.TempECampaignCustomerCourseRank t2 (nolock)
                    where t2.CustomerID = t.CustomerID
                    order by t2.FinalRank
                    for xml path('') 
                )
                from Staging.TempECampaignCustomerCourseRank t (nolock)
                group by t.CustomerID
        )
        select distinct 
            c.CustomerID, 
            rtrim(c.LastName) as LastName, 
            rtrim(c.FirstName) as FirstName, 
            c.EmailAddress, 
            'N' as Unsubscribe,
            Convert(varchar(15),'VALID') as EmailStatus, 
            convert(varchar(300),c.SubjectLine) SubjectLine, 
            convert(varchar(2000),CustHTML) CustHTML,
            Convert(varchar(50),c.Region) as State,
            c.AdCode, 
            isnull(replace(c.PreferredCategory,' ',''),'GEN') as PreferredCategory, 
            c.ComboID,
            DATEPART(day,@Startdate) as SendDate,
            case
                when c.CustomerID < 89999999 then isnull(sz.TimeGroup, 6) -- to not affect the seed emails
            end as BatchID,
            c.ECampaignID, 
            @DeadlineDate as DeadlineDate, 
            CONVERT(varchar(50),'') as Subject,
            convert(varchar(50),'BestCust') as CatalogName,
  /*          case
                when c.AdCode = @AdcodeActive then cast(1 as bit)
                else cast(0 as bit)
            end as FlagAdcodeActive,*/
            c.CustomerSegmentNew,
            c.CustomerID + '_' + CONVERT(varchar, c.Adcode) as UserID
        into Staging.TempECampaignEmailTemplate
        from Staging.TempECampaignEmailableCustomers c (nolock)
        join cteHTML t on t.CustomerID = c.CustomerID
        left join Mapping.StateZone sz (nolock) on sz.[State] = c.Region
	end    
    
   	if @LogicName = 'AddToEmailHistory'
	begin    
	
		PRINT 'In CampaignEmail_ExecuteSharedLogic AddToEmailHistory'
	
        INSERT INTO Archive.EmailHistory
        (CustomerID,Adcode,StartDate)
        SELECT Customerid,
            Adcode,
            @StartDate
        FROM Staging.TempECampaignEmailableCustomers (nolock)
    end
    
   	if @LogicName = 'CreateFinalTables'
	begin    
	
		PRINT 'In CampaignEmail_ExecuteSharedLogic CreateFinalTables'
		
        if object_id('Ecampaigns.dbo.' + @TablePrefix + '_CourseRank') is not null 
        begin
            set @SQLStatement = 'drop table Ecampaigns.dbo.' + @TablePrefix + '_CourseRank'
            exec sp_executesql @SQLStatement
        end
        set @SQLStatement = 'select * into Ecampaigns.dbo.' + @TablePrefix + '_CourseRank from Staging.TempECampaignCourseRank2 (nolock)'
        exec sp_executesql @SQLStatement
        
        if object_id('Ecampaigns.dbo.' + @TablePrefix + '_EmailableCustomers') is not null 
        begin
            set @SQLStatement = 'drop table Ecampaigns.dbo.' + @TablePrefix + '_EmailableCustomers'
            exec sp_executesql @SQLStatement
        end
        set @SQLStatement = 'select * into Ecampaigns.dbo.' + @TablePrefix + '_EmailableCustomers from Staging.TempECampaignEmailableCustomers (nolock)'
        exec sp_executesql @SQLStatement
        
        if object_id('Ecampaigns.dbo.' + @TablePrefix + '_CustomerCourseRank') is not null 
        begin
            set @SQLStatement = 'drop table Ecampaigns.dbo.' + @TablePrefix + '_CustomerCourseRank'
            exec sp_executesql @SQLStatement
        end
        set @SQLStatement = 'select * into Ecampaigns.dbo.' + @TablePrefix + '_CustomerCourseRank from Staging.TempECampaignCustomerCourseRank (nolock)'
        exec sp_executesql @SQLStatement
        
        if object_id('Ecampaigns.dbo.' + @TablePrefix + '_EmailTemplate') is not null 
        begin
            set @SQLStatement = 'drop table Ecampaigns.dbo.' + @TablePrefix + '_EmailTemplate'
            exec sp_executesql @SQLStatement
        end
        set @SQLStatement = 'select * into Ecampaigns.dbo.' + @TablePrefix + '_EmailTemplate from Staging.TempECampaignEmailTemplate (nolock)'
        exec sp_executesql @SQLStatement
    end

END
GO
