SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadWPEmail]
as
	declare
    	@PullDate date,
        @StartDate date,
        @EndDate date
begin
	--set nocount on

    set @PullDate = dateadd(dd, 1 - datepart(dw, getdate()), getdate()) /* Sunday of the current week*/
    /*set @StartDate = dateadd(wk, -6, @PullDate) /* Sunday 6 weeks ago*/
    set @EndDate = dateadd(wk, -5, @PullDate) /* Sunday 5 weeks ago */  */ 
    -- PR 7/8/2013 -- Starting this week, WP expires after 4 weeks instead of 5 weeks. 
    --                So, change these start and end dates to correct dates
    set @StartDate = dateadd(wk, -5, @PullDate) /* Sunday 6 weeks ago*/
    set @EndDate = dateadd(wk, -4, @PullDate) /* Sunday 5 weeks ago */
    
    PRINT '@PullDate = ' + convert(varchar,@PullDate)
    PRINT '@StartDate = ' + convert(varchar,@StartDate)
    PRINT '@EndDate = ' + convert(varchar,@EndDate)    
    
	exec Staging.LoadWPCustomers @PullDate, @StartDate, @EndDate, 'EmailPull'

	truncate table Staging.WPEmail
    insert INTO Staging.WPEmail
    (
    	CustomerID,
        FirstName, 
        LastName, 
        EmailAddress, 
        Adcode, 
        COUPONCODE, 
        CouponExpire, 
        WPDROPDATE,
        ECampaignID,
        CRComboID,
        CourseID,
        [Rank],
        CustomerSegmentNew
    )
    SELECT 
    	c.CUSTOMERID, 
        CCS.FirstName, 
        CCS.LastName, 
        CCS.EmailAddress, 
        CASE 
        	WHEN c.PackageType = 'New' THEN 28898
            ELSE 28899
        END AS Adcode, 
        cP.COUPONCODE, 
        cP.ExpirationPrintedDate, 
        CONVERT(DATETIME, cP.ExpirationPrintedDate,101) - 34 AS WPDROPDATE,
         'WPE' + replace(convert(varchar, cp.ExpirationPrintedDate, 101), '/', '') AS ECampaignID,
         ccs.CRComboID,
         cr.CourseID,
         cr.[Rank],
         ccs.CustomerSegmentNew
    FROM Staging.WPEmailCustomers c (nolock)
    JOIN Marketing.CampaignCustomerSignature CCS (nolock) ON c.CustomerID = CCS.CustomerID
    join Mapping.WPCoupons cp (nolock) on cp.WeekOfMailing = dateadd(day, 1, @EndDate)
   -- join Mapping.DMCourseRanking Cr (nolock) ON replace(replace(replace(ccs.CRComboID,'PR','SCI'),'FW','SCI'),'SC','SCI') = Cr.CRComboID  -- PR 11/18/2013 Some are getting messed up by this replace.
    join Mapping.DMCourseRanking Cr (nolock) ON isnull(CCS.CRComboID,'SCI-M-02-03') = Cr.CRComboID
    WHERE 
    	c.PackageType IN ('New','Returning')
	    AND CCS.FlagEmail = 1 
        AND CCS.PublicLibrary = 0
    	and CCS.CountryCode not in ('GB','AU')
        
	/* Delete if they have purchased the courses.*/
	delete e
	from Staging.WPEmail e
    join Marketing.CompleteCoursePurchase c (nolock) on c.customerid = e.customerid and c.courseid = e.courseid
       
	-- Remove courses that should not be in Welcome Packages
	DELETE A
	FROM Staging.WPEmail A LEFT OUTER JOIN
		Mapping.WPCoursesFP B (nolock) ON a.courseid=b.courseid
	WHERE B.CourseID IS NULL
    
            
	/* Delete discontinued courses*/
    DELETE WP
    FROM Staging.WPEmail WP LEFT OUTER JOIN
        (SELECT DISTINCT CourseID 
        FROM Staging.Invitem (nolock)
        WHERE forsaleonweb=1 
        AND forsaletoconsumer=1 
        AND itemcategoryid in ('course','bundle'))Crs ON WP.CourseID = Crs.CourseID
    WHERE Crs.CourseID is NULL 
    
    delete r
    from Staging.WPEmail r
    join 
    (
        select CustomerID, [rank], rank() over (partition by customerid order by [rank]) as CourseRank
        from Staging.WPEmail (nolock)
    ) r2 on r.CustomerID = r2.CustomerID and r.[Rank] = r2.[Rank] and r2.CourseRank > 25
    
    update r
    set r.Rank = r2.CourseRank
    from Staging.WPEmail r
    join 
    (
        select CustomerID, [rank], rank() over (partition by customerid order by [rank]) as CourseRank
        from Staging.WPEmail (nolock)
    ) r2 on r.CustomerID = r2.CustomerID and r.[Rank] = r2.[Rank]
    
    update Staging.WPEmail
    set firstname='Lifelong',
          lastname='Learner'
    where upper(firstname) like 'ACCOUNT%' or 
    upper(firstname) like 'ACQUISI%' or
    upper(firstname) like 'DON''%' or
    upper(firstname) like 'KNOW' or
    upper(firstname) like 'PAYABLE%' or
    upper(Lastname) like 'ACCOUNT%' or 
    upper(lastname) like 'ACQUISI%' or
    upper(lastname) like 'DON''%' or
    upper(lastname) like 'KNOW' or
    upper(lastname) like 'PAYABLE%'
    
    ;with _duplicates as 
    (    
        select distinct t.CustomerID, t.EmailAddress, rank() over (partition by t.EmailAddress order by t.CustomerID) Num
        from Staging.WPEmail t (nolock)    
    )
    delete wpe
    from Staging.WPEmail wpe
    join _duplicates d (nolock) on d.CustomerID = wpe.CustomerID and wpe.EmailAddress = d.EmailAddress and d.Num > 1 

/* 
    -- if they received DRTV convertalog test, then they should get control adcode    
    update A
    SET A.Adcode = 28898
    FROM Staging.WPEmail a  JOIN
          rfm..WPPackage09262011_e  b on a.customerID = b.customerid
    where b.adcode in (52104,59854,59853,58472)

    -- If they did not receive WP mail, then adcode them separately.
    UPDATE A
    SET A.Adcode = CASE WHEN a.aDcode = 28898 then 30094
                      ELSE 30095
                END
    FROM rfm.dbo.WPEMAIL_09262011_NEWNoWP a left outer JOIN
          rfm..WPPackage09262011_e  b on a.customerID = b.customerid
          where b.customerid is null    
*/
end
GO
