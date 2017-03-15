SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
--	Description: Flatten out the preferences data to make it easier to use
------------------------------------------------------------------------------------------------------------------------------------------
--	Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
--	US550	06/29/2015	BryantJ			Initial.
------------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[V_Preferences]
AS
SELECT ep.preference_id,
	ep.email,
	ep.guest_key,
	ep.created_date,
	ep.last_updated_date,
	ep.snooze_start_date,
	ep.snooze_end_date,
	ers.name AS registration_source,
	CASE WHEN epo1.Is_Exists IS NOT NULL
			THEN 1
		ELSE 0
	END AS Has_New_Course_Announcement,
	CASE WHEN epo2.Is_Exists IS NOT NULL
			THEN 1
		ELSE 0
	END AS Has_Free_Lectures,
	CASE WHEN epo3.Is_Exists IS NOT NULL
			THEN 1
		ELSE 0
	END AS Has_Exclusive_Offers,
	CASE WHEN epo1.Is_Exists IS NOT NULL
			THEN epo3.Frequency
		ELSE NULL
	END AS New_Course_Announcement_Frequency
FROM epc_preference ep
	LEFT JOIN epc_registration_source ers
		ON ep.registration_source_id = ers.registration_source_id
	OUTER APPLY (SELECT MAX(1) Is_Exists FROM epc_preference_option epo 
				WHERE ep.preference_id = epo.preference_id
					AND option_id = 1
				) epo1
	OUTER APPLY (SELECT MAX(1) Is_Exists FROM epc_preference_option epo 
				WHERE ep.preference_id = epo.preference_id
					AND option_id = 2
				) epo2
	OUTER APPLY (SELECT MAX(1) Is_Exists, MAX(name) Frequency FROM epc_preference_option epo 
					INNER JOIN epc_frequency ef
						ON epo.frequency_id = ef.frequency_id
				WHERE ep.preference_id = epo.preference_id
					AND option_id = 3
				) epo3

GO
