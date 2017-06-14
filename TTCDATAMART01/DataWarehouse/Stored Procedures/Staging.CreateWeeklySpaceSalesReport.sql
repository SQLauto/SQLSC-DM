SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Staging].[CreateWeeklySpaceSalesReport]
	@EndDate DATETIME = '1/1/1900'
AS
BEGIN
	set nocount on
/*- Proc Name: 	MarketingDM.dbo.CreateWeeklySpaceSalesRpt*/
/*- Purpose:	To generate Weekly Space Sales report*/
/*- Updates:*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	7/18/2007	New*/
/*- Preethi Ramanujam	10/29/2007	Changed the Startdate from '9/1/2003' to Jan 1 of the previous year.*/

SET Transaction isolation Level read uncommitted
/*- Declare variables*/

DECLARE @NewEndDate DATETIME,
	@Today DATETIME,
	@StartDate DATETIME

/*SELECT @EndDate*/

SET @Today = CONVERT(DATETIME, CONVERT(VARCHAR(10),  GETDATE(), 101))

IF @EndDate = '1/1/1900'
   BEGIN
	SET @NewEndDate = GETDATE() - (DATEPART(dw, @Today)-1)
	SET @EndDate = @NewEndDate
   END

DECLARE @TempStartDate VARCHAR(20)	/* PR 10/29/2007*/
SET @TempStartDate = '1/1/' + CONVERT(VARCHAR,(YEAR(@EndDate) - 1))
/*SELECT @TempStartDate*/

SET @StartDate = CONVERT(DATETIME,@TempStartDate)

/* SELECT @EndDate, @NewEndDate, @Today, @StartDate*/
truncate table Staging.SpaceSales_Adocdes

insert into Staging.SpaceSales_Adocdes 
select MAC.*, MCC.StartDate, MCC.StopDate,
		MCC.DaxMktCampaign, mdc.MD_Campaign     			
from Staging.MktAdcodes MAC (nolock) left join
	  Staging.MktCatalogCodes MCC (nolock) ON MAC.CatalogCode = MCC.CatalogCode left outer join
	  Mapping.DMPromotionType dmp on MCC.CatalogCode = dmp.CatalogCode left outer join
	  Mapping.MktDim_Campaign mdc on MCC.DaxMktCampaign = mdc.MD_CampaignID
where MCC.DaxMktChannel in (4)  -- Added this to include all the space ads even if they are missing from dmpromotiontype
union
select MAC.*, MCC.StartDate, MCC.StopDate,
		MCC.DaxMktCampaign, mdc.MD_Campaign
from Staging.MktAdcodes MAC (nolock) left join
	  Staging.MktCatalogCodes MCC (nolock) ON MAC.CatalogCode = MCC.CatalogCode left outer join
	  Mapping.DMPromotionType dmp on MCC.CatalogCode = dmp.CatalogCode left outer join
	  Mapping.MktDim_Campaign mdc on MCC.DaxMktCampaign = mdc.MD_CampaignID
where dmp.PromotionType like '%space%'

truncate table Staging.SpaceSales_SpaceMaster

insert INTO Staging.SpaceSales_SpaceMaster
SELECT 
    isnull(MAC.MD_Campaign, 'CampaignName_Missing') AS CampaignName,
    132 as AdID, 
    MAC.Adcode, 
    MAC.Name AS AdCodeName,
    MAC.Description AS AdcodeDescription,
	CONVERT(VARCHAR,MIN(O.DateOrdered),101) AS MinOfDateOrdered, 
    CONVERT(VARCHAR,MAX(O.DateOrdered),101) AS MaxOfDateOrdered,
    SUM(O.NetOrderAmount) AS SumOfNetOrderAmount, 
    COUNT(DISTINCT O.OrderID) AS CountOfOrderID,
	sum(case when O.SequenceNum = 1 then NetOrderAmount else 0 end) NewCustSales,
	sum(case when O.SequenceNum = 1 then 0 else NetOrderAmount end) ExistingCustSales,
	sum(case when O.SequenceNum = 1 then 1 else 0 end) NewCustOrders,
	sum(case when O.SequenceNum = 1 then 0 else 1 end) ExistingCustOrders,
    ISNULL(CONVERT(VARCHAR,MAC.StartDate,101),'') AS StartDate, 
    '' AS SaleDate,
    CONVERT(VARCHAR(30),  GETDATE(), 101) AS ReportPullDate
--into Staging.SpaceSales_SpaceMaster
FROM Marketing.DMPurchaseOrders O (nolock) JOIN
     -- Staging.vwOrders O  (nolock) JOIN
	  Staging.SpaceSales_Adocdes MAC ON O.Adcode = MAC.Adcode 
/*    SuperStarDW.dbo.MktCampaign MC ON MC.CampaignID = MCC.CampaignID -- NOT IN DAX*/
WHERE O.StatusCode in (0,1,2,3,12,13)
      /*MAC.AdID =132  -- NOT IN DAX
      AND ISNULL(MAC.SaleDate,'12/31/2003') >= '11/20/2003' -- NOT IN DAX
      AND ((O.StatusCode IN (0,1,2,3,7) and o.FlagLegacy = 'True') or (o.FlagLegacy = 'False' and o.StatusCode <> 4 ))
      AND */
      AND O.DateOrdered BETWEEN '9/1/2003' AND GETDATE()
      AND O.NetOrderAmount > 0 AND O.NetOrderAmount < 1500
GROUP BY 
      MAC.DaxMktCampaign,
      MAC.MD_Campaign, MAC.Adcode, MAC.Name, MAC.Description,
	MAC.StartDate, MAC.SaleDate
ORDER BY 1,3

truncate table Staging.SpaceSales

insert INTO Staging.SpaceSales
SELECT 
    isnull(MAC.MD_Campaign, 'CampaignName_Missing') AS CampaignName,
    MAC.Adcode, 
    MAC.Name AS AdCodeName,
    MAC.Description AS AdcodeDescription,
	CONVERT(VARCHAR,MIN(O.DateOrdered),101) AS MinOfDateOrdered, 
    CONVERT(VARCHAR,MAX(O.DateOrdered),101) AS MaxOfDateOrdered,
    SUM(NetOrderAmount) AS SumOfNetOrderAmount, 
	COUNT(DISTINCT OrderID) AS CountOfOrderID,
	sum(case when O.SequenceNum = 1 then NetOrderAmount else 0 end) NewCustSales,
	sum(case when O.SequenceNum = 1 then 0 else NetOrderAmount end) ExistingCustSales,
	sum(case when O.SequenceNum = 1 then 1 else 0 end) NewCustOrders,
	sum(case when O.SequenceNum = 1 then 0 else 1 end) ExistingCustOrders,
    ISNULL(CONVERT(VARCHAR,MAC.StartDate,101),'') AS StartDate, 
    CONVERT(VARCHAR(30),  GETDATE(), 101) AS ReportPullDate
--	into Staging.SpaceSales
FROM 
      --Staging.vwOrders O  (nolock) JOIN
	  Marketing.DMPurchaseOrders O (nolock) JOIN
      Staging.SpaceSales_Adocdes MAC ON O.Adcode = MAC.Adcode 
/*    SuperStarDW.dbo.MktCampaign MC ON MC.CampaignID = MCC.CampaignID -- NOT IN DAX*/
WHERE O.StatusCode in (0,1,2,3,12,13)
      /*MAC.AdID =132  -- NOT IN DAX
      AND ISNULL(MAC.SaleDate,'12/31/2003') >= '11/20/2003' -- NOT IN DAX
      AND ((O.StatusCode IN (0,1,2,3,7) and o.FlagLegacy = 'True') or (o.FlagLegacy = 'False' and o.StatusCode <> 4 ))
      AND */
      AND O.DateOrdered BETWEEN @StartDate AND @EndDate
      AND O.NetOrderAmount > 0 AND O.NetOrderAmount < 1500
GROUP BY 
      MAC.DaxMktCampaign,
      MAC.MD_Campaign, MAC.Adcode, MAC.Name, MAC.Description,MAC.StartDate, MAC.SaleDate
ORDER BY 1,3


    
END
GO
