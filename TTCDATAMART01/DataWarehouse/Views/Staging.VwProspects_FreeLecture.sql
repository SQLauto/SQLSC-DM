SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Staging].[VwProspects_FreeLecture]
AS
    
select cast(WEBDATECOLLECTED as date) WebDate, 
	Year(WEBDATECOLLECTED) WebCllctYear, Month(WEBDATECOLLECTED) WebCllctMonth, 
	a.PROSPECTID, a.CUSTACCOUNT, a.EMAILADDRESS,
	a.EMAILCONFIRMED, a.INITIALSOURCECODE, b.AdcodeName as InitialSourceCodeName,
	a.WEBDATECOLLECTED, a.MODIFIEDDATETIME, CREATEDDATETIME, ISACCOUNTWHENCREATED, -- IsAccountWhenCreated is only looking at web account -- PR 10/3/2014
	a.INITIALUSERAGENT, c.CustomerSince,
	--case when DATEDIFF(DAY,a.webdatecollected,c.CustomerSince) >= 0 and ISACCOUNTWHENCREATED = 0 then 1 else 0 end as FlagProspect,
	case when DATEDIFF(DAY,a.webdatecollected,c.CustomerSince) < 0 then 1 else 0 end as FlagExistingCustomer, 
	GETDATE() as ReportDate
from DAXImports..TTCPROSPECTS a left join
	Mapping.vwAdcodesAll b on a.INITIALSOURCECODE = b.AdCode left join
	(select distinct customerID, customerSince
	from DataWarehouse.Staging.Customers
	where ISNULL(customerid,'') <> '')c on a.CUSTACCOUNT = c.customerid
-- where WEBDATECOLLECTED between '12/6/2013' and GETDATE() -- resetting this to new website start date. Becuase definition of IsAccountWhenCreated flag has changed.
where WEBDATECOLLECTED between '8/1/2014' and GETDATE()



GO
