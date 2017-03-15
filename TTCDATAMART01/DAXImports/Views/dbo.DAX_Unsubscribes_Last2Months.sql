SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [dbo].[DAX_Unsubscribes_Last2Months]
AS
    
  select distinct a.CUSTACCOUNT as CustomerID, 
		b.EMAIL as EmailAddress,
		GETDATE() as PullDate
  FROM [DAXImports].[dbo].[TTC_AUDITCUSTOPTINCHANGES] a join
	DAXImports.dbo.CustomerExport b on a.CUSTACCOUNT = b.Customerid left join
	(select a.*
	from DAXImports..TTC_AUDITCUSTOPTINCHANGES a join
		(select CUSTACCOUNT, OPTINID, max(MODIFIEDDATETIME) MaxDate
		from [DAXImports].[dbo].[TTC_AUDITCUSTOPTINCHANGES] 
		where OPTINID = 'OfferEmail'
		group by CUSTACCOUNT, OPTINID)b on a.CUSTACCOUNT = b.CUSTACCOUNT
							and a.MODIFIEDDATETIME = b.MaxDate
							and a.OPTINID = b.OPTINID
	where a.ACTIONREQUESTED = 'Subscribe')c on a.CUSTACCOUNT = c.CUSTACCOUNT
  where a.ACTIONREQUESTED = 'Unsubscribe'
  and a.OPTINID = 'OfferEmail'
  and a.MODIFIEDDATETIME >= DATEADD(month, -3, getdate())
  and b.EMAIL like '%@%'
  and c.CUSTACCOUNT is null
 

GO
