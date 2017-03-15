SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
--	Description: Flatten out the survey data to make it easier to use
------------------------------------------------------------------------------------------------------------------------------------------
--	Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
--	US550	06/29/2015	BryantJ			Initial.
------------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[V_Survey]
AS
SELECT 
	es.survey_id,
	es.preference_id,
	es.created_date,
	es.feedback,
	CASE WHEN esq1.Is_Exists IS NOT NULL
			THEN 1
		ELSE 0
	END AS Has_Too_Many_Emails,
	CASE WHEN esq2.Is_Exists IS NOT NULL
			THEN 1
		ELSE 0
	END AS Has_No_Longer_Interested,
	CASE WHEN esq3.Is_Exists IS NOT NULL
			THEN 1
		ELSE 0
	END AS Has_I_Have_Too_Many_Courses,
	CASE WHEN esq4.Is_Exists IS NOT NULL
			THEN 1
		ELSE 0
	END AS Has_Offers_Not_Valuable,
	CASE WHEN esq5.Is_Exists IS NOT NULL
			THEN 1
		ELSE 0
	END AS Has_Prefere_To_Receive_Catalogs
FROM epc_survey es
	OUTER APPLY (SELECT MAX(1) Is_Exists FROM epc_survey_question esq 
				WHERE es.survey_id = esq.survey_id
					AND esq.reason_id = 1
				) esq1
	OUTER APPLY (SELECT MAX(1) Is_Exists FROM epc_survey_question esq 
				WHERE es.survey_id = esq.survey_id
					AND esq.reason_id = 2
				) esq2
	OUTER APPLY (SELECT MAX(1) Is_Exists FROM epc_survey_question esq 
				WHERE es.survey_id = esq.survey_id
					AND esq.reason_id = 3
				) esq3
	OUTER APPLY (SELECT MAX(1) Is_Exists FROM epc_survey_question esq 
				WHERE es.survey_id = esq.survey_id
					AND esq.reason_id = 4
				) esq4
	OUTER APPLY (SELECT MAX(1) Is_Exists FROM epc_survey_question esq 
				WHERE es.survey_id = esq.survey_id
					AND esq.reason_id = 5
				) esq5

GO
