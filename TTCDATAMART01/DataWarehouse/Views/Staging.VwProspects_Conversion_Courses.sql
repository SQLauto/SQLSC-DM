SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Staging].[VwProspects_Conversion_Courses]
AS
    
select cast(WEBDATECOLLECTED as date) WebDate, 
	a.PROSPECTID, 
	a.CUSTACCOUNT, 
	a.EMAILADDRESS,
	a.EMAILCONFIRMED, 
	a.INITIALSOURCECODE, 
	b.AdcodeName as InitialSourceCodeName,
	a.WEBDATECOLLECTED, 
	a.MODIFIEDDATETIME, 
	CREATEDDATETIME, 
	CONVERSIONDATE,
	ISACCOUNTWHENCREATED,
	a.INITIALUSERAGENT, GETDATE() as ReportDate,
	case when a.CUSTACCOUNT > 0 then 'Customer'
		else 'Prospect'
	end as CustType,
	DATEDIFF(day,a.WebdateCollected,a.CONVERSIONDATE) As DaysToConvert,
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then 1
		else 0
	end as FlagConverted,	
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then c.LTDPurchases
		else 0
	end as ConversionOrders, 
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then c.LTDPurchAmount
		else 0
	end as ConversionSales, 	
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then d.PromotionType
		else null
	end IntlPromotionTypeID, 
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then d.PRtype 
		else null
	end IntlPromotionType,
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then d.AdCode
		else null
	end IntlPurchaseAdCode, 
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then d.AdcodeName
		else null
	end as IntlPurchaseAdCodeName, 
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then d.CatalogCode 
		else null
	end as IntlPurchaseCatCode, 
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then d.CatalogName
		else null
	end as IntlPurchaseCatName,
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then d.NetOrderAmount
		else null
	end as IntlPurchaseAmount,
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then g.OrderItemID
		else null
	end as OrderItemID,
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then g.BundleID
		else null
	end as BundleID,
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then g.CourseID		
		else null
	end as CourseID, 
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then g.CourseName		
		else null
	end as CourseName, 
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then g.Parts 
		else null
	end as CourseParts, 
	case when a.CUSTACCOUNT > 0 and a.ISACCOUNTWHENCREATED = 0 then h.MediaTypeID
		else null
	end as Format
from DAXImports..TTCPROSPECTS a join
	DataWarehouse.Mapping.vwAdcodesAll b on a.INITIALSOURCECODE = b.AdCode 
	left join DataWarehouse.Marketing.CustomerDynamicCourseRank c on a.CUSTACCOUNT = c.CustomerID 
	left join (select d.*, f.AdcodeName, f.CatalogName, f.PromotionType as PRtype
				from (select * from DataWarehouse.Marketing.DMPurchaseOrders
				--where DateOrdered > '12/1/2013'	and SequenceNum = 1)d 
				where DateOrdered > '8/1/2014'	and SequenceNum = 1)d 
				left join DataWarehouse.Mapping.vwAdcodesAll f on d.AdCode = f.AdCode)d on a.CUSTACCOUNT = d.CustomerID  
	left join DataWarehouse.Marketing.DMPurchaseOrderItems g on d.OrderID = g.OrderID 
	left join Staging.InvItem h on g.StockItemID = h.StockItemID
	left join (select distinct customerID, customersince
				from Staging.Customers 
				where ISNULL(customerid,'') <> '')i on a.CUSTACCOUNT = i.CustomerID
-- where WEBDATECOLLECTED between '12/6/2013' and GETDATE()
where WEBDATECOLLECTED between '8/1/2014' and GETDATE()






GO
