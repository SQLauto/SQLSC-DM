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
CREATE VIEW [Magento].[V_pivot_tgc_upsell_customer_list]
AS
	SELECT
		dax_customer_id, 
		location_id, 
		CONVERT(VARCHAR(MAX),dbo.GROUP_CONCAT_D(CONVERT(VARCHAR(16),list_id),'|')) AS ranked_list_ids,
		MAX(last_updated_date) AS Max_Last_Updated_Date
	FROM Magento.tgc_upsell_customer_list
	GROUP BY dax_customer_id, 
		location_id
GO
