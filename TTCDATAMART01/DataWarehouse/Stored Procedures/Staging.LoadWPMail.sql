SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadWPMail]
AS
	DECLARE 
    	@todayDate DATETIME,
		@PullDate  DATE,	
		@startDate DATETIME,
		@endDate   DATETIME,
        @sql nvarchar(1000),
        @table_name nvarchar(100),
        @CouponCode varchar(6),
        @CouponExpire date
begin
	--set nocount on
    
	select top 1 @PullDate = FMPullDate from Marketing.CampaignCustomerSignature (nolock)
    
    if @PullDate <> cast(getdate() as date)
    begin
		raiserror('FMPullDate from CampaignCustomerSignature differs from today''s date', 0, 0)
		return
    end
    
	SET @todayDate = CONVERT(DATETIME, CONVERT(VARCHAR(10),  GETDATE(), 101))

	IF (DATEPART(dw, @todayDate) not in (2,3,4,5,6))
		RAISERROR ('Today is not a Weekday', 20, 1)

	SET @pullDate = @todayDate - (DATEPART(dw, @todayDate)-1)
	SET @startDate = @todayDate - (DATEPART(dw, @todayDate)+6)
	SET @endDate = @todayDate - (DATEPART(dw, @todayDate)-1)
	
	print '@pullDate = ' + convert(varchar,@pulldate)	
	print '@StartDate = ' + convert(varchar,@StartDate)
	print '@endDAte = ' + convert(varchar,@endDAte)
    
    select 
    	@CouponCode = c.CouponCode,
        @CouponExpire = c.ExpirationPrintedDate
	from Mapping.WPCoupons c (nolock)
    where c.WeekOfMailing = dateadd(day,1,@endDate)

	execute Staging.LoadWPCustomers @pullDate, @startDate, @endDate, 'MailPull'

/* SK: DEL?   
	truncate table Staging.MostRecent3Orders

	INSERT INTO Staging.MostRecent3Orders
    (
    	CustomerID, 
        OrderID, 
        DateOrdered,
        OrderItemID,
        SubjectCategory2,
        Parts
    )
    select 
        O.CustomerID, 
        O.OrderID, 
        O.DateOrdered,
        oi.OrderItemID,
        oi.SubjectCategory2,
        oi.TotalParts
    from 
    (
        SELECT DISTINCT 
            O.CustomerID, 
            O.OrderID, 
            O.DateOrdered,
            rank() over (partition by o.CustomerID order by o.DateOrdered desc) as OrderRecencyRank           
        FROM Marketing.DMPurchaseOrders O (nolock)
        where
        	StatusCode in (0, 1, 2, 3, 12, 13)
            AND O.NetOrderAmount > 0        
	) o
	join Staging.ValidPurchaseOrderItems OI (nolock) on O.OrderID = OI.OrderID 
    join Staging.InvItem I (nolock) on OI.StockItemID = I.StockItemID
    join Staging.WPMailCustomers wpc (nolock) on wpc.CustomerID = o.CustomerID
    WHERE 
    	wpc.PackageType IN ('New', 'Returning')
        and I.StockItemID LIKE '[PD][AVCD]%' 
		and o.OrderRecencyRank <= 3
*/        
    
	truncate table Staging.WPMailRank

/*
	INSERT INTO Staging.WPMailRank
    (
		CustomerID,
        SubjectCategory2,
        PastOrdersBin,
        Gender,
        CRComboID	        
    )
	SELECT 
    	T.CustomerID, 
        T.SubjectCategory2, 
        pob.PastOrdersBin,
		CASE 
        	WHEN REPLACE(CG.Gender,' ','') IN ('F','M') THEN CG.Gender
			ELSE 'O'
		END AS Gender,
		REPLACE(T.SubjectCategory2, ' ', '') + '-' + 
        CASE 
        	WHEN REPLACE(CG.Gender,' ','') IN ('F','M') THEN REPLACE(CG.Gender,' ','')
			ELSE 'O'
		END + '-' + pob.PastOrdersBin           
	FROM Staging.vwPastOrdersBinWP pob (nolock)
    join 
    (
		select 
			CustomerID, 
		    v.SubjectCategory2, 
			rank() over (partition by CustomerID order by v.MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc) as PreferenceRank
		from Staging.vwCustomerSubjectCategory2PreferencesWP v (nolock)
	) T on T.CustomerID = pob.CustomerID
    left join Staging.CustomerGender cg on pob.CustomerID = cg.CustomerID
    where t.PreferenceRank = 1
*/    
	INSERT INTO Staging.WPMailRank
    (
		CustomerID,
        CourseID,
        [Rank]
    )
    select 
        wpc.CustomerID,
        cr.CourseID,
        cr.[Rank]    
    from Staging.WPMailCustomers wpc (nolock)
    join Marketing.CampaignCustomerSignature ccs (nolock) on ccs.CustomerID = wpc.CustomerID
    join Mapping.DMCourseRanking cr (nolock) on isnull(ccs.CRComboID, 'X-O-02-03') = cr.CRComboID 

	/* delete prior purchases*/
	print 'delete prior purchases'
	delete wpr
    from Staging.WPMailRank wpr
    join Marketing.CompleteCoursePurchase ccp (nolock) on wpr.CustomerID = ccp.CustomerID AND wpr.CourseID = ccp.CourseID
    
	-- Remove Discontinued Courses
	print 'Remove Discontinued Courses'
	DELETE WP
	FROM Staging.WPMailRank WP LEFT OUTER JOIN
		(SELECT DISTINCT CourseID 
		FROM Staging.Invitem (nolock)
		WHERE forsaleonweb=1 
		AND forsaletoconsumer=1 
		AND itemcategoryid in ('course','bundle'))Crs ON WP.CourseID = Crs.CourseID
	WHERE Crs.CourseID is NULL
    
	-- Remove courses that should not be in Welcome Packages
	print 'Remove courses that should not be in Welcome Packages'
	DELETE A
	FROM Staging.WPMailRank A LEFT OUTER JOIN
		Mapping.WPCoursesFP B (nolock) ON a.courseid=b.courseid
	WHERE B.CourseID IS NULL
    
    update wpr
   	set wpr.FinalRank = t.FinalRank
    from Staging.WPMailRank wpr
    join 
    (
        select 
            t.CustomerID,
            t.[Rank],
            rank() over (partition by customerid order by rank) as FinalRank
        from Staging.WPMailRank t (nolock)
	) t on t.CustomerID = wpr.CustomerID and t.[Rank] = wpr.Rank
    
	delete from Staging.WPMailRank
	where FinalRank > 3
--	where FinalRank > 11
    
	truncate table Staging.TempWPMail
	insert into Staging.TempWPMail
    (
        CustomerID,
        CustomerName,
        [Prefix],
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        Address1,
        Address2,
        City,
        Region,
        PostalCode,
        CouponExpire,
        Adcode,
        CouponCode,
        CourseID1,
        CourseID2,
        CourseID3,
        CourseID4,
        CourseID5,
        CourseID6,
        CourseID7,
        CourseID8,
        CourseID9,
        CourseID10,
        CourseID11,
        URLVariable,
        VersionCode,
        ConvertalogAdcode,
        FlagEmailable,
        CustomerSegmentNew
    )
	SELECT DISTINCT 
    	WP.CustomerID, 
        Convert(varchar(255),Replace(CCS.FirstName,' ','') + ' ' + Replace(CCS.LastName,' ','') + ' ' + Replace(CCS.Suffix,' ','')) AS CustomerName,
		CCS.Prefix, 
        CCS.FirstName, 
        CCS.MiddleName, 
        CCS.LastName, 
        CCS.Suffix,
		CCS.Address1, 
        CCS.Address2, 
        CCS.City, 
        CCS.State as Region, 
        CCS.PostalCode, 
        @CouponExpire, 
		CASE 
        	WHEN isnull(ccs.FlagEmail, 0) = 1 and wpc.PackageType = 'Returning' then 32640
            when wpc.PackageType = 'Returning' then 18156 
			ELSE 59854
		END AS Adcode,
		@CouponCode, 
        0 AS CourseID1, 
        0 AS CourseID2, 
        0 AS CourseID3,
		0 AS CourseID4, 
        0 AS CourseID5, 
        0 AS CourseID6,
		0 AS CourseID7, 
        0 AS CourseID8, 
        0 AS CourseID9,
		0 AS CourseID10, 
        0 AS CourseID11,
		@CouponCode AS URLVariable,
        CASE 
        	WHEN wp.SubjectCategory2 IN ('EC','HS') THEN 'CV-SCI'
			ELSE 'CV-' + wp.SubjectCategory2 
		END as VersionCode,
        0,
        isnull(ccs.FlagEmail, 0) as FlagEmailable,
        ccs.CustomerSegmentNew 
	FROM Staging.WPMailRank WP (nolock) JOIN
		Marketing.CampaignCustomerSignature CCS (nolock) ON WP.CustomerID = CCS.CustomerID JOIN
		Staging.WPMailCustomers WPC (nolock) ON WPC.CustomerID = WP.CustomerID
    WHERE WPC.PackageType IN ('New','Returning')
    AND CCS.FlagMail = 1 AND CCS.PublicLibrary = 0
    aND CCS.FlagValidRegionUS = 1
    
	-- update for 3 courses (was 11 before)
    UPDATE WPN
    SET WPN.CourseID1 = WFN.CourseID
    FROM Staging.TempWPMail WPN JOIN
        Staging.WPMailRank WFN (nolock) ON WPN.CustomerID = WFN.CustomerID
    WHERE WFN.FinalRank = 1
    
    UPDATE WPN
    SET WPN.CourseID2 = WFN.CourseID
    FROM Staging.TempWPMail WPN JOIN
        Staging.WPMailRank WFN (nolock) ON WPN.CustomerID = WFN.CustomerID
    WHERE WFN.FinalRank = 2
    
    UPDATE WPN
    SET WPN.CourseID3 = WFN.CourseID
    FROM Staging.TempWPMail WPN JOIN
        Staging.WPMailRank WFN (nolock) ON WPN.CustomerID = WFN.CustomerID
    WHERE WFN.FinalRank = 3

/*    
    UPDATE WPN
    SET WPN.CourseID4 = WFN.CourseID
    FROM Staging.TempWPMail WPN JOIN
        Staging.WPMailRank WFN ON WPN.CustomerID = WFN.CustomerID
    WHERE WFN.FinalRank = 4
    
    UPDATE WPN
    SET WPN.CourseID5 = WFN.CourseID
    FROM Staging.TempWPMail WPN JOIN
        Staging.WPMailRank WFN ON WPN.CustomerID = WFN.CustomerID
    WHERE WFN.FinalRank = 5
    
    UPDATE WPN
    SET WPN.CourseID6 = WFN.CourseID
    FROM Staging.TempWPMail WPN JOIN
        Staging.WPMailRank WFN ON WPN.CustomerID = WFN.CustomerID
    WHERE WFN.FinalRank = 6
    
    UPDATE WPN
    SET WPN.CourseID7 = WFN.CourseID
    FROM Staging.TempWPMail WPN JOIN
        Staging.WPMailRank WFN ON WPN.CustomerID = WFN.CustomerID
    WHERE WFN.FinalRank = 7
    
    UPDATE WPN
    SET WPN.CourseID8 = WFN.CourseID
    FROM Staging.TempWPMail WPN JOIN
        Staging.WPMailRank WFN ON WPN.CustomerID = WFN.CustomerID
    WHERE WFN.FinalRank = 8
    
    UPDATE WPN
    SET WPN.CourseID9 = WFN.CourseID
    FROM Staging.TempWPMail WPN JOIN
        Staging.WPMailRank WFN ON WPN.CustomerID = WFN.CustomerID
    WHERE WFN.FinalRank = 9
    
    UPDATE WPN
    SET WPN.CourseID10 = WFN.CourseID
    FROM Staging.TempWPMail WPN JOIN
        Staging.WPMailRank WFN ON WPN.CustomerID = WFN.CustomerID
    WHERE WFN.FinalRank = 10
    
    UPDATE WPN
    SET WPN.CourseID11 = WFN.CourseID
    FROM Staging.TempWPMail WPN JOIN
        Staging.WPMailRank WFN ON WPN.CustomerID = WFN.CustomerID
    WHERE WFN.FinalRank = 11
*/    
    
    delete from Staging.TempWPMail
    where customerid in (
    select min(mail.customerid) customerid
    from 	(SELECT distinct mail.customerid, mail.prefix, ltrim(rtrim(mail.firstname)) as FirstName, 
        mail.MiddleName, ltrim(rtrim(mail.lastname))lastname, mail.suffix, 
        ltrim(rtrim(Mail.Address1)) Address1, 
        ltrim(rtrim(mail.Address2)) Address2, ltrim(rtrim(Mail.city)) City, 
        ltrim(rtrim(mail.Region)) Region, Mail.PostalCode,ccs.EmailAddress
    from  Staging.TempWPMail mail join
        (SELECT Address1,Address2,City,Region,FirstName,LastName,Postalcode,count(customerID) custcount
        from Staging.TempWPMail 
        group by Address1,Address2,City,Region,FirstName,LastName,Postalcode
        having count(customerid) > 1)dupes on mail.address1=dupes.address1 and mail.city=dupes.city join
        Marketingdm.dbo.campaigncustomersignature ccs on mail.customerid = ccs.customerid)mail
    group by  mail.firstname, mail.lastname,
        Mail.Address1, mail.address2, mail.city)
        
    set @table_name = 'RFM.dbo.WPMail' + convert(varchar, getdate(), 112)
    print 'Final table name: ' + @table_name
    
    if object_id(@table_name) is not null
    begin
        set @SQL = 'drop table ' + @table_name
        exec sp_executesql @sql
    end            
        	
    set @sql = 'select * into ' + @table_name + ' from Staging.TempWPMail'
    exec sp_executesql @sql

	truncate table Staging.TempWPMail
end
GO
