SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_RAM_CustomerCohort_Daily]
as
Begin

Truncate table DataWarehouse.Mapping.RAM_CustomerCohort

Insert into DataWarehouse.Mapping.RAM_CustomerCohort

select 
 ccs.CustomerID,
 case when right(ccs.CustomerID,1) in (0,1,2,3,4,5) then 'TEST' else 'CONTROL' End AS CustGroup,
 ccs.NewSeg, ccs.Name, 
 ccs.a12mf,ccs.Frequency, ccs.ComboID, DATEDIFF(Month, DM.DateOrdered, GETDATE()) Recency,
 ccs.Concatenated,ccs.CustomerSegment, ccs.FMPullDate, 
 ccs.CustomerSegmentNew, 
 ccs.CustomerSegment2, ccs.CustomerSegmentFnl,
 DM.CustomerSegmentFnlPrior,  DM.NewsegPrior,   
 DM.NamePrior,isnull(DM.A12mfPrior,0) as A12mfPrior, DM.FrequencyPrior,
 DM.ConcatenatedPrior,M.Comboid as ComboidPrior,DM.DateOrdered as LastOrderDate ,GETDATE() as lastupdated
from DataWarehouse.Marketing.CampaignCustomerSignature ccs 
join [Staging].[vwCustomerLastOrders_DMPOrders] DM 
on CCS.CustomerID = DM.customerid
left join Mapping.RFMComboLookup M
on DM.NewsegPrior=M.Newseg and DM.NamePrior=M.Name and isnull(DM.A12mfPrior,0)=M.A12mf and DM.ConcatenatedPrior = M.Concatenated
where ccs.NewSeg in (3,4,5,8,9,10)
and DM.customersegmentfnlprior in ('DeepInactive_Multi','DeepInactive_Single','Inactive_Single') --Removed 'Active_Multi' as we are not using archive.RAM_CustomerCohort table VB 2017/1/4
and ccs.CountryCode = 'US'




End
GO
