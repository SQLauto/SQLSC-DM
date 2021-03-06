SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [dbo].[VwProspects_FreeLecture]
AS
    
select cast(WEBDATECOLLECTED as date) WebDate, a.PROSPECTID, a.CUSTACCOUNT, a.EMAILADDRESS,
	a.EMAILCONFIRMED, a.INITIALSOURCECODE, b.AdcodeName,
	a.WEBDATECOLLECTED, a.MODIFIEDDATETIME, CREATEDDATETIME, ISACCOUNTWHENCREATED,
	a.INITIALUSERAGENT, GETDATE() as ReportDate
from DAXImports..TTCPROSPECTS a join
	DataWarehouse.Mapping.vwAdcodesAll b on a.INITIALSOURCECODE = b.AdCode left join
	superstardw..WebStreamingProgress c on a.CUSTACCOUNT = c.Customerid
where WEBDATECOLLECTED between '12/6/2013' and GETDATE()

GO
