SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE View [Archive].[Vw_TGCPlus_PASCountryOfSubscription]
as

select distinct pas.pa_user_id, pas.country_of_subscription, pas.pas_created_at, tc.Country
from Archive.TGCPlus_PaymentAuthorizationStatus pas
join (select minc.pa_user_id, max(minc.Minpas_created_at) Minpas_created_at
	from (select 	pa_user_id, country_of_subscription, min(pas_created_at) Minpas_created_at
			from Archive.TGCPlus_PaymentAuthorizationStatus
			where isnull(country_of_subscription,'') <> ''
			group by pa_user_id, country_of_subscription)minc
	group by minc.pa_user_id)c on pas.pa_user_id = c.pa_user_id
							and pas.pas_created_at = c.Minpas_created_at
 left join Mapping.TGCPlusCountry tc on pas.country_of_subscription = tc.Alpha2Code						

GO
