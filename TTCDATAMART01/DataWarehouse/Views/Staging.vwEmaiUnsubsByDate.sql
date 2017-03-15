SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Staging].[vwEmaiUnsubsByDate]
AS
    select a.AsOfDate,	
		YEAR(a.Asofdate) AsOfYear,
		MONTH(a.asofdate) AsOfMonth,
		a.FlagEmailPref,
		COUNT(a.customerid) CustCount
	from DataWarehouse.Archive.CustomerOptinTracker a join	
		(select CustomerID, MIN(Asofdate) Mindate
		 from DataWarehouse.Archive.CustomerOptinTracker
		where FlagEmailPref = 0
		group by CustomerID)b on a.CustomerID = b.CustomerID and a.AsOfDate = b.Mindate
	where a.FlagEmailPref = 0	
	group by a.AsOfDate,	
		YEAR(a.Asofdate),
		MONTH(a.asofdate),
		a.FlagEmailPref


GO
