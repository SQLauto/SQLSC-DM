SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Group Concat'ing the values for export
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2277	07/05/2016	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW [Magento].[V_pivot_tgc_upsell_you_may_like]
AS
	SELECT 
		list_id, 
		course_id, 
		CONVERT(VARCHAR(MAX),dbo.GROUP_CONCAT_D(CONVERT(VARCHAR(16),recommended_course_id),'|')) AS ranked_recommended_course_ids
	FROM Magento.tgc_upsell_you_may_like 
	GROUP BY list_id, 
		course_id
GO
