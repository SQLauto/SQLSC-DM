SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Staging].[LoadCustomerSubjectMatrix]
	@AsOfDate datetime = null
as
begin
    set nocount on
    
    set @AsOfDate = isnull(@AsOfDate, getdate())
    
    print 'Run LoadRFMData'
    exec Staging.LoadRFMData @AsOfDate
    
    print 'Run LoadMostRecentOrders'
	exec Staging.LoadMostRecentOrders @AsOfDate, 'CSM'    
    
    print 'update CustomerSubjectMatrix temp table'
	select *
    into #CustomerSubjectMatrix
    from Marketing.CustomerSubjectMatrix (nolock)
    where 0=1
    
	insert into #CustomerSubjectMatrix
    (
    	CustomerID,
        TranscriptOnly,
        HSOnly,
        HSandCollege,
        CollegeOnly,
        [Active]
    )
	select distinct 
    	CustomerID,
        0,
        0,
        0,
        0,
        0
    from Marketing.CompleteCoursePurchase (nolock)
    where DateOrdered < @AsOfDate
    
    UPDATE CSM
    SET 	
        CSM.RL = ISNULL(RL.RL,0),
        CSM.LIT = ISNULL(LIT.LIT,0),
        CSM.SC = ISNULL(SC.SC,0),
        CSM.PH = ISNULL(PH.PH,0),
        CSM.AH = ISNULL(AH.AH,0),
        CSM.MH = ISNULL(MH.MH,0),
        CSM.HS = ISNULL(HS.HS,0),
        CSM.EC = ISNULL(EC.EC,0),
        CSM.FA = ISNULL(FA.FA,0),
        CSM.FW = ISNULL(FW.FW, 0),
        CSM.PR = ISNULL(PR.PR, 0),
        CSM.HSFormat = ISNULL(HSFormat.HSFormat,0),
        CSM.Audio = ISNULL(Audio.Audio,0),
        CSM.Video = ISNULL(Video.Video,0), 
        CSM.Downloads = ISNULL(DLs.Downloads,0),
        CSM.CD = ISNULL(CD.CD,0), 
        CSM.DVD = ISNULL(DVD.DVD,0), 
        CSM.Transcript = ISNULL(Trns.Transcript,0),
        CSM.VideoDownloads = ISNULL(VideoDownloads.VideoDownloads, 0),
        -- subject category 2 data
        csm.SCI = isnull(sci.sci, 0),
        csm.MTH = isnull(mth.mth, 0),
        csm.VA = isnull(va.va, 0), 
        csm.MSC = isnull(msc.msc, 0)
    FROM #CustomerSubjectMatrix CSM 
   	LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS RL, customerid 
        FROM Marketing.CompleteCoursePurchase (nolock)
        WHERE DateOrdered < @AsOfDate and SubjectCategory = 'RL'
    ) RL ON RL.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS LIT, customerid 
        FROM Marketing.CompleteCoursePurchase (nolock)
        WHERE DateOrdered < @AsOfDate and SubjectCategory = 'LIT'
    ) LIT ON LIT.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS SC, customerid 
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE SubjectCategory = 'SC' AND ccp.DateOrdered < @AsOfDate
    ) SC ON SC.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS PH, customerid 
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE SubjectCategory = 'PH' AND ccp.DateOrdered < @AsOfDate
    ) PH ON PH.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS AH, customerid 
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE SubjectCategory = 'AH' AND ccp.DateOrdered < @AsOfDate
    ) AH ON AH.CustomerID = CSM.CustomerID
	LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS MH, customerid 
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE SubjectCategory = 'MH' AND ccp.DateOrdered < @AsOfDate
    ) MH ON MH.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS HS, customerid 
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE SubjectCategory = 'HS' AND ccp.DateOrdered < @AsOfDate
    ) HS ON HS.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS EC, customerid 
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE SubjectCategory = 'EC' AND ccp.DateOrdered < @AsOfDate
    ) EC ON EC.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS FA, customerid 
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE SubjectCategory = 'FA' AND ccp.DateOrdered < @AsOfDate
    ) FA ON FA.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS FW, customerid 
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE SubjectCategory = 'FW' AND ccp.DateOrdered < @AsOfDate
    ) FW ON FW.CustomerID = CSM.CustomerID
	LEFT OUTER JOIN        
    (
    	SELECT DISTINCT 1 AS PR, customerid 
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE SubjectCategory = 'PR' AND ccp.DateOrdered < @AsOfDate
    ) PR ON PR.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS HSFormat, CustomerID
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE SubjectCategory = 'HS' and ccp.DateOrdered < @AsOfDate
    ) HSFormat ON HSFormat.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS Audio, CustomerID
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE StockItemID LIKE 'PA%' AND SubjectCategory <> 'HS' and ccp.DateOrdered < @AsOfDate
    ) Audio ON Audio.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS Video, CustomerID
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE StockItemID LIKE 'PV%' AND SubjectCategory <> 'HS' and ccp.DateOrdered < @AsOfDate
    ) Video ON Video.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT  DISTINCT 1 AS Downloads, CustomerID
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE StockItemID LIKE 'DA%' AND SubjectCategory <> 'HS' and ccp.DateOrdered < @AsOfDate
    ) DLs ON DLs.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT  DISTINCT 1 AS DVD, CustomerID
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE StockItemID LIKE 'P[DM]%' AND SubjectCategory <> 'HS' and ccp.DateOrdered < @AsOfDate
    ) DVD ON DVD.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS CD, CustomerID
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE StockItemID LIKE 'P[CM]%' AND SubjectCategory <> 'HS' and ccp.DateOrdered < @AsOfDate
    ) CD ON CD.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
        SELECT DISTINCT 1 AS Transcript, CustomerID
        FROM Marketing.CompleteTranscriptPurchase t (nolock)
        WHERE 
            SubjectCategory <> 'HS'
            and t.DateOrdered < @AsOfDate
    ) Trns ON Trns.CustomerID = CSM.CustomerID
    LEFT OUTER JOIN
    (
    	SELECT DISTINCT 1 AS VideoDownloads, CustomerID
        FROM Marketing.CompleteCoursePurchase ccp (nolock)
        WHERE StockItemID LIKE 'DV%' AND SubjectCategory <> 'HS' and ccp.DateOrdered < @AsOfDate
    ) VideoDownloads ON VideoDownloads.CustomerID = CSM.CustomerID
    left join 
    (
        select distinct 1 as sci, CustomerID
        from Marketing.CompleteCoursePurchase ccp (nolock)
        where SubjectCategory2 = 'SCI' AND ccp.DateOrdered < @AsOfDate
    ) sci on sci.CustomerID = csm.CustomerID
    left join 
    (
        select distinct 1 as mth, CustomerID
        from Marketing.CompleteCoursePurchase ccp (nolock)
        where SubjectCategory2 = 'MTH' AND ccp.DateOrdered < @AsOfDate
    ) mth on mth.CustomerID = csm.CustomerID
    left join 
    (
        select distinct 1 as va, CustomerID
        from Marketing.CompleteCoursePurchase ccp (nolock)
        where SubjectCategory2 = 'VA' AND ccp.DateOrdered < @AsOfDate
    ) va on va.CustomerID = csm.CustomerID
    left join 
    (
        select distinct 1 as msc, CustomerID
        from Marketing.CompleteCoursePurchase ccp (nolock)
        where SubjectCategory2 = 'MSC' AND ccp.DateOrdered < @AsOfDate
    ) msc on msc.CustomerID = csm.CustomerID
    
	UPDATE CsM 
    SET 
    	HSOnly = 1 
	FROM #CustomerSubjectMatrix CsM
	WHERE 
    	CsM.HS = 1 
        AND CsM.AH = 0 
        AND CsM.EC = 0 
        AND (CsM.FA = 0 or (csm.va = 0 and csm.MSC = 0))
        AND CsM.LIT = 0
		AND CsM.MH = 0 
        AND CsM.PH = 0 
        AND CsM.RL = 0 
        AND (CsM.SC = 0 or (csm.sci = 0 and csm.MTH = 0))
        and csm.FW = 0
        and csm.PR = 0
    
	UPDATE CsM 
    SET TranscriptOnly = 1
	FROM #CustomerSubjectMatrix CsM
    join Marketing.CompleteCoursePurchase ccp (nolock) on ccp.CustomerID = csm.CustomerID
	WHERE 
    	CsM.Transcript = 1 
        AND CsM.Audio = 0 
        AND CsM.Video = 0 
        AND CsM.CD = 0 
        AND CsM.DVD = 0 
		AND CsM.Downloads = 0 
        AND csm.HSFormat = 0
        and csm.VideoDownloads = 0
		AND ccp.SubjectCategory <> 'HS'
        and ccp.DateOrdered < @AsOfDate

	UPDATE CCM 
    SET CollegeOnly = 1 
	FROM #CustomerSubjectMatrix CCM
	WHERE HSOnly <> 1 
    
	UPDATE CsM 
    SET HSAndCollege = 1
	FROM #CustomerSubjectMatrix CsM
	WHERE 
    	HS = 1 
        AND 
        (
        	CsM.AH = 1 
            OR CsM.EC = 1 
            OR CsM.FA = 1 
            OR CsM.LIT = 1 
            OR CsM.MH = 1 
            OR CsM.PH = 1 
            OR CsM.RL = 1 
            OR CsM.SC = 1
            or csm.PR = 1
            or csm.FW = 1
            or csm.SCI = 1
            or csm.MTH = 1
            or csm.VA = 1
            or csm.MSC = 1
		)

	UPDATE CSM
	SET 	
    	CSM.RFMStatus = RDS.Concatenated,
		CSM.A12MF = RDS.A12MF,			/* PR - Added this on 9/11/2007*/
		CSM.Active = 
		CASE 	
            WHEN RI.NewSeg BETWEEN 1 AND 10 THEN 1
			WHEN RI.NewSeg BETWEEN 13 AND 15 THEN 1
			ELSE 0
		END,
		CSM.NewSeg = RI.NewSeg,
		CSM.Name = RN.Name
	FROM #CustomerSubjectMatrix CSM
    join Marketing.RFM_DATA_SPECIAL RDS (nolock) on CSM.CustomerID = RDS.CustomerID
    join Mapping.RFMInfo RI (nolock) on RDS.Concatenated = RI.Concatenated
	join Mapping.RFMNewSegs RN (nolock) on RI.NewSeg = RN.NewSeg
    
/*
	;with PreferredCategory( CustomerID, SubjectCategory, RankNum ) as
    (
        SELECT 
            CustomerID, 
            SubjectCategory, 
			rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc)
        FROM Staging.vwCustomerSubjectCategoryPreferences
    )
	UPDATE CSM
	SET CSM.PreferredCategory = pc.SubjectCategory
	FROM #CustomerSubjectMatrix CSM
    join 
    (
    	select 
        	CustomerID,
			SubjectCategory            
	    from PreferredCategory  
    	where RankNum = 1
	) pc on pc.CustomerID = csm.CustomerID        
*/    
	UPDATE CSM
	SET CSM.PreferredCategory = cp.SubjectCategory
	FROM #CustomerSubjectMatrix CSM
    join Staging.vwCustomerSubjectCategoryPreferences cp (nolock) on cp.CustomerID = csm.CustomerID        
	where RankNum = 1   /* Added Code to update based on rank 1 Vikram 9/19/2016 */
/*    
	;with PreferredCategory2( CustomerID, SubjectCategory2, RankNum ) as
    (
        SELECT 
            CustomerID, 
            SubjectCategory2, 
			rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc)
        FROM Staging.vwCustomerSubjectCategory2Preferences
    )
	UPDATE CSM
	SET CSM.PreferredCategory2 = pc.SubjectCategory2
	FROM Staging.TempCustomerSubjectMatrix CSM
    join 
    (
    	select 
        	CustomerID,
			SubjectCategory2            
	    from PreferredCategory2 
    	where RankNum = 1
	) pc on pc.CustomerID = csm.CustomerID        
*/    
	UPDATE CSM
	SET CSM.PreferredCategory2 = cp.SubjectCategory2
	FROM #CustomerSubjectMatrix CSM
    join Staging.vwCustomerSubjectCategory2Preferences cp (nolock) on cp.CustomerID = csm.CustomerID        
    where RankNum = 1

    truncate table Marketing.CustomerSubjectMatrix    
    insert into Marketing.CustomerSubjectMatrix
    select * from #CustomerSubjectMatrix (nolock)

END

GO
