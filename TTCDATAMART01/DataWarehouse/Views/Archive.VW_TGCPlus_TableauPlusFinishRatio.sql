SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[VW_TGCPlus_TableauPlusFinishRatio] 
as
Select
a.*,
b.genre,
c.IntlMD_Channel,
c.IntlSubType,
c.CustStatusFlag, c.DSMonthCancelled, 
c.PaidFlag, 
case	
	when c.TGCCustFlag = 1 then 'TGC Customer' else 'Not a TGC Customer' end as TGCCustomerFlag
from marketing.tgcplus_LTDCourseConsumption (nolock) a 
		left join (Select distinct course_Id, genre from archive.tgcplus_film (nolock)) b on a.Course_id = b.course_id
		join marketing.TGCPlus_CustomerSignature (nolock) c on a.id = c.CustomerID;
GO
