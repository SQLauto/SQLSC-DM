SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create view [Staging].[Vw_DW_Unsubscribes_Last2Months]
AS
    
select CustomerID, EmailAddress, GETDATE() as PullDate
 FROM Archive.CustomerOptinTracker
 where FlagEmailPref = 0
 and EmailAddress like '%@%'
 group by CustomerID, EmailAddress
 having MIN(AsofDate) >= DATEADD(month, -2, getdate())


GO
