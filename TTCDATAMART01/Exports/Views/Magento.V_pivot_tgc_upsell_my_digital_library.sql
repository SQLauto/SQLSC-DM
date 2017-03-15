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
CREATE VIEW [Magento].[V_pivot_tgc_upsell_my_digital_library]
AS
	SELECT 
		list_id, 
		CONVERT(VARCHAR(MAX),dbo.GROUP_CONCAT_D(CONVERT(VARCHAR(16),recommended_course_id),'|')) AS ranked_recommended_course_ids
	FROM Magento.tgc_upsell_my_digital_library 
	GROUP BY list_id
GO
