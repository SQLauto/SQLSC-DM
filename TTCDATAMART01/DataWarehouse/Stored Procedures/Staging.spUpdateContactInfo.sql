SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROCEDURE [Staging].[spUpdateContactInfo]
	@AsOfDate 	DATETIME
AS
	/*
	Updates All Contacts Subsequent Month Information in TempCustomerDynamic
	Author:- 	J P Gorti
	Date:-		05/01/2005

	Change History:
	Name			Date		Comments
	Preethi Ramanujam	10/23/2007	Added Cost information to update the new columns
	Preethi Ramanujam	10/31/2007	Added Magazine Contact information and also included
						FlagHoldout to avoid including holdout groups in the count.
	*/	

/* Update Total Contact information*/

		UPDATE TCD
			SET TCD.ContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH INNER JOIN 
					Staging.MktAdCodes MAC ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	MH.FlagHoldout = 0 AND /*DP.PromotionType = 'Catalog' AND */
					(MH.StartDate >= @AsOfDate AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDate))
				GROUP BY MH.CustomerID) T
			ON TCD.AsOfdate = @AsOfdate
			WHERE TCD.CustomerID = T.CustomerID

/* Update Catalog contacts information*/
		UPDATE TCD
			SET TCD.CatalogContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostCatalogContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH INNER JOIN 
					Staging.MktAdCodes MAC ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	DP.PromotionType = 'Catalog' AND MH.FlagHoldout = 0 AND 
					(MH.StartDate >= @AsOfDate AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDate))
				GROUP BY MH.CustomerID) T
			ON TCD.AsOfdate = @AsOfdate
			WHERE TCD.CustomerID = T.CustomerID

/* Update Newsletter contacts information*/
		UPDATE TCD
			SET TCD.NLContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostNLContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH INNER JOIN 
					Staging.MktAdCodes MAC ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	DP.PromotionType = 'NewsLetter' AND MH.FlagHoldout = 0 AND 
					(MH.StartDate >= @AsOfDate AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDate))
				GROUP BY MH.CustomerID) T
			ON TCD.AsOfdate = @AsOfdate
			WHERE TCD.CustomerID = T.CustomerID

/* Update Magalog contacts information*/
		UPDATE TCD
			SET TCD.MagalogContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostMagalogContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH INNER JOIN 
					Staging.MktAdCodes MAC ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	DP.PromotionType = 'Magalog' AND MH.FlagHoldout = 0 AND 
					(MH.StartDate >= @AsOfDate AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDate))
				GROUP BY MH.CustomerID) T
			ON TCD.AsOfdate = @AsOfdate
			WHERE TCD.CustomerID = T.CustomerID

/* Update Swamp specific contacts information*/
		UPDATE TCD
			SET TCD.SwampSpContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostSwampSpContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM  Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH INNER JOIN 
					Staging.MktAdCodes MAC ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	DP.PromotionType = 'SwampSpecific' AND MH.FlagHoldout = 0 AND 
					(MH.StartDate >= @AsOfDate AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDate))
				GROUP BY MH.CustomerID) T
			ON TCD.AsOfdate = @AsOfdate
			WHERE TCD.CustomerID = T.CustomerID

/* Update Magazine contacts information*/
		UPDATE TCD
			SET TCD.MagazineContactsSubsqMth = T.Cnt1YearCatalogContacts,
			    TCD.CostMagazineContactsSubsqMth = T.Cost1YearCatalogContacts /* PR - 10/23/2007*/
			FROM Staging.TempDMCustomerDynamic TCD INNER JOIN  
				(SELECT MH.CustomerID, COUNT(MH.AdCode) Cnt1YearCatalogContacts,
					SUM(MAC.VariableCost) Cost1YearCatalogContacts /* PR - 10/23/2007*/
				FROM 	Archive.MailingHistory MH INNER JOIN 
					Staging.MktAdCodes MAC ON MH.AdCode = MAC.AdCode 
					INNER JOIN Mapping.DMPromotionType DP ON MAC.CatalogCode = DP.CatalogCode 
				WHERE 	DP.PromotionType = 'Magazine' AND MH.FlagHoldout = 0 AND 
					(MH.StartDate >= @AsOfDate AND MH.STartDate < 	DATEADD(MM, 1, @AsOfDate))
				GROUP BY MH.CustomerID) T
			ON TCD.AsOfdate = @AsOfdate
			WHERE TCD.CustomerID = T.CustomerID
GO
