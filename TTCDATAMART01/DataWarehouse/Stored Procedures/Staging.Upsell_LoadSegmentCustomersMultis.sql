SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[Upsell_LoadSegmentCustomersMultis]
AS
BEGIN
	set nocount on
    
    if object_id('Staging.TempUpsell_SegmentCustomersMultis') is not null drop table Staging.TempUpsell_SegmentCustomersMultis
	
	SELECT 
    	p.CustomerID, 
        p.SubjectPreferenceID, 
        pob.PastOrdersBin
	INTO Staging.TempUpsell_SegmentCustomersMultis
	FROM Staging.vwPastOrdersBin pob (nolock)
    join Staging.vwCustomerPCASubjectPreferenceID p (nolock) on p.CustomerID = pob.CustomerID
    join Marketing.CustomerSubjectMatrix csm (nolock) on csm.CustomerID = p.CustomerID
    where 
    	p.RankNum = 1
        and csm.RFMStatus like '%F2%'

END
GO
