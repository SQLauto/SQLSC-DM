SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadUpsellRecos]
AS
BEGIN
    set nocount on
    
	exec Staging.LoadMostRecentOrders null, 'UR'        
    exec Staging.LoadSegmentCustomers
    
    if object_id('Staging.TempUpsellRank') is not null drop table Staging.TempUpsellRank
    if object_id('Staging.TempCCUpsellRecos') is not null drop table Staging.TempCCUpsellRecos
    if object_id('Staging.TempCCUpsellRecosReRanked') is not null drop table Staging.TempCCUpsellRecosReRanked        

	SELECT 
    	p.CustomerID, 
        p.SubjectPreferenceID, 
        pob.PastOrdersBin,
        COM.Courseid,
        COM.[Rank]
	INTO Staging.TempUpsellRank        
	FROM Staging.vwPastOrdersBin pob (nolock)
    join Staging.vwCustomerPCASubjectPreferenceID p (nolock) on p.CustomerID = pob.CustomerID
    join Mapping.CourseOfferMaster COM (nolock) on p.SubjectPreferenceID = COM.SubjectPreferenceID AND pob.PastOrdersBin = COM.PastOrdersBin 	
    where p.RankNum = 1

	/* delete prior purchases */
	delete ur
    from Staging.TempUpsellRank ur
    join Marketing.CompleteCoursePurchase ccp (nolock) on ur.CustomerID = ccp.CustomerID AND ur.CourseID = ccp.CourseID

	SELECT 
    	W.CustomerID, 
        W.CourseID, 
        W.[Rank], 
        v.LastOrderDate
	INTO Staging.TempCCUpsellRecos        
	FROM Staging.TempUpsellRank W (nolock) 
    JOIN Marketing.CustomerSubjectMatrix CSM (nolock) ON W.CustomerID = CSM.CustomerID AND CSM.RFMStatus LIKE '%F2%'
	join Staging.vwCustomerLastOrderDate v (nolock) on v.CustomerID = csm.CustomerID
    	
	INSERT INTO Staging.TempCCUpsellRecos (CustomerID, CourseID, Rank, LastOrderDate)
	SELECT 	SC.CustomerID, UCR.CourseID, UCR.Rank, v.LastOrderDate
	FROM 	Staging.SegmentCustomers SC (nolock) INNER JOIN Mapping.UpsellCourseRank UCR (nolock)
		ON SC.SegmentGroup = UCR.SegmentGroup
    join Staging.vwCustomerLastOrderDate v (nolock) on v.CustomerID = sc.CustomerID    
	WHERE	sc.CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Staging.TempCCUpsellRecos (nolock))

	DELETE FROM C1 
	FROM Staging.TempCCUpsellRecos C1 INNER JOIN Marketing.CompleteCoursePurchase CC (nolock)
		ON C1.CustomerID = CC.CustomerID AND
		C1.CourseID = CC.CourseID

	--5/10/12/SK: re-rank courses and limit by 30
	;with cteReRanking(CustomerID, CourseID, [Rank], LastOrderDate) as        
    (
        select 
        	t.CustomerID, 
            t.CourseID,
	        rank() over (partition by CustomerID order by [Rank]) as [Rank],
            LastOrderDate
        from Staging.TempCCUpsellRecos t (nolock)
    )
    select *
    into Staging.TempCCUpsellRecosReRanked
	from cteReRanking 
    where [Rank] <= 23

    if object_id('RFM.dbo.CCUpsellRecos') is not null drop table RFM.dbo.CCUpsellRecos
    select * into RFM.dbo.CCUpsellRecos from Staging.TempCCUpsellRecosReRanked (nolock)
   
    if object_id('Staging.TempUpsellRank') is not null drop table Staging.TempUpsellRank 
    if object_id('Staging.TempCCUpsellRecos') is not null drop table Staging.TempCCUpsellRecos    
    if object_id('Staging.TempCCUpsellRecosReRanked') is not null drop table Staging.TempCCUpsellRecosReRanked            
END
GO
