SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_MC_TGC_MailContacts] @MonthStartDate Date = Null,@Year int = null
as
Begin

/*
If We want last month to refresh then we do not need to pass any parameters.
If we want to refresh a Particular MonthStartDate to process we need to pass @MonthStartDate as Parameter.
If we want to refresh a Particular MonthStartDate to process we need to pass @MonthStartDate as Parameter.

*/

Declare @SQL Nvarchar(4000)

	 If @MonthStartDate is null and @Year is null
		  Begin
				
			If object_id('Staging.MC_TGC_MailingContact') is not null
				Begin 
				Drop table Staging.MC_TGC_MailingContact
				End 

			 /* MailingHistory_Convertalog*/
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0) as MonthStartDate
			  into Staging.MC_TGC_MailingContact
			  from Archive.MailingHistory_Convertalog
			  where DATEADD(month, DATEDIFF(month, 0, StartDate), 0) = DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0) 
			  AND FlagHoldOut = 0
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)
			  Union All
			/*WPArchiveNew */
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, WeekOfMailing), 0) as MonthStartDate
			  from Archive.WPArchiveNew  
			  where AdCode not in (18156,32640)   
			  and DATEADD(month, DATEDIFF(month, 0, WeekOfMailing), 0) = DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0) 
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, WeekOfMailing), 0)
			  Union All

			/*CatRqst*/
			 select CustomerID,CatalogAdcode as Adcode,DATEADD(month, DATEDIFF(month, 0, ShipDate), 0) as MonthStartDate
			  from Archive.MailingHistory_CatRqst  
			  where CatalogAdcode not in (18156,32640)   
			  and DATEADD(month, DATEDIFF(month, 0, ShipDate), 0) = DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0) 
			  group by CustomerID,CatalogAdcode,DATEADD(month, DATEDIFF(month, 0, ShipDate), 0)
			  Union All
			 /*NCJFY*/			  
 			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, JFYMailDate), 0) as MonthStartDate
			  from Archive.MailingHistory_NCJFY  
			  where Adcode not in (18156,32640)   
			  and DATEADD(month, DATEDIFF(month, 0, JFYMailDate), 0) = DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0) 
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, JFYMailDate), 0)
			  Union All

			/*MailingHistory*/
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)  as MonthStartDate
			  from Archive.MailhistoryCurrentYear
			  where AdCode not in (18156,32640)   
			  AND FlagHoldOut = 0
			  and DATEADD(month, DATEDIFF(month, 0, StartDate), 0) = DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0) 
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)

		  End
	
	
	If  @MonthStartDate is not Null and Datepart(d,@MonthStartDate) <> 1
	Begin 
	select @MonthStartDate 'Before'
	set @MonthStartDate = DATEADD(month, DATEDIFF(month, 0, @MonthStartDate), 0) 
	select @MonthStartDate 'After'
	End
		  
	If @MonthStartDate is Not null and @Year is null 
		   Begin
 

			  Declare   @Year@MonthStartDate int

			  set @Year@MonthStartDate = Year(@MonthStartDate)
			  set @SQL = '
			  	If object_id(''Staging.MC_TGC_MailingContact'') is not null
				Begin 
				Drop table Staging.MC_TGC_MailingContact
				End 

			/* MailingHistory_Convertalog*/
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0) as MonthStartDate
			  into Staging.MC_TGC_MailingContact
			  from Archive.MailingHistory_Convertalog
			  where DATEADD(month, DATEDIFF(month, 0, StartDate), 0) = ''' + Cast(@MonthStartDate as Varchar(10)) + ''' 
			  AND FlagHoldOut = 0
			  and Year(DATEADD(month, DATEDIFF(month, 0, StartDate), 0)) = ' + Cast(@Year@MonthStartDate as Varchar(4)) + '
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)
			  Union All
			/*WPArchiveNew */
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, WeekOfMailing), 0) as MonthStartDate
			  from Archive.WPArchiveNew  
			  where AdCode not in (18156,32640)   
			  and DATEADD(month, DATEDIFF(month, 0, WeekOfMailing), 0) = ''' + Cast(@MonthStartDate as Varchar(10)) + '''  
			  and Year(DATEADD(month, DATEDIFF(month, 0, WeekOfMailing), 0)) = ' + Cast(@Year@MonthStartDate as Varchar(4)) + '
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, WeekOfMailing), 0)
			  Union All

			 /*CatRqst*/
			 select CustomerID,CatalogAdcode as Adcode,DATEADD(month, DATEDIFF(month, 0, ShipDate), 0) as MonthStartDate
			  from Archive.MailingHistory_CatRqst  
			  where CatalogAdcode not in (18156,32640)   
			  and DATEADD(month, DATEDIFF(month, 0, ShipDate), 0) = ''' + Cast(@MonthStartDate as Varchar(10)) + '''  
			  and Year(DATEADD(month, DATEDIFF(month, 0, ShipDate), 0)) = ' + Cast(@Year@MonthStartDate as Varchar(4)) + '
			  group by CustomerID,CatalogAdcode,DATEADD(month, DATEDIFF(month, 0, ShipDate), 0)
			  Union All
			 /*NCJFY*/			  
 			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, JFYMailDate), 0) as MonthStartDate
			  from Archive.MailingHistory_NCJFY  
			  where Adcode not in (18156,32640)   
			  and DATEADD(month, DATEDIFF(month, 0, JFYMailDate), 0) = ''' + Cast(@MonthStartDate as Varchar(10)) + '''  
			  and Year(DATEADD(month, DATEDIFF(month, 0, JFYMailDate), 0)) = ' + Cast(@Year@MonthStartDate as Varchar(4)) + '
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, JFYMailDate), 0)
			  Union All

			/*MailingHistory*/
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)  as MonthStartDate
			  from Archive.Mailinghistory' + Cast(@Year@MonthStartDate as Varchar(4)) + '
			  where AdCode not in (18156,32640)   
			  AND FlagHoldOut = 0
			  and DATEADD(month, DATEDIFF(month, 0, StartDate), 0) = ''' + Cast(@MonthStartDate as Varchar(10)) + '''  
			  and Year(DATEADD(month, DATEDIFF(month, 0, StartDate), 0)) =  ' + Cast(@Year@MonthStartDate as Varchar(4)) + '
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)'

			  Print @SQL

			  Exec (@SQL)

		   End

	If @Year is Not null
		   Begin

			  set @SQL = '
			  	If object_id(''Staging.MC_TGC_MailingContact'') is not null
				Begin 
				Drop table Staging.MC_TGC_MailingContact
				End 

			  /* MailingHistory_Convertalog*/
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0) as MonthStartDate
			  into Staging.MC_TGC_MailingContact
			  from Archive.MailingHistory_Convertalog
			  where Year(DATEADD(month, DATEDIFF(month, 0, StartDate), 0)) = ' + Cast(@Year as Varchar(4)) + '
			  AND FlagHoldOut = 0
			  and DATEADD(month, DATEDIFF(month, 0, StartDate), 0) <= DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0)
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)
			  Union All
			/*WPArchiveNew */
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, WeekOfMailing), 0) as MonthStartDate
			  from Archive.WPArchiveNew  
			  where AdCode not in (18156,32640)   
			  and Year(DATEADD(month, DATEDIFF(month, 0, WeekOfMailing), 0)) = ' + Cast(@Year as Varchar(4)) + '
			  and DATEADD(month, DATEDIFF(month, 0, WeekOfMailing), 0) <= DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0)
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, WeekOfMailing), 0)
			  Union All
			 /*CatRqst*/
			 select CustomerID,CatalogAdcode as Adcode,DATEADD(month, DATEDIFF(month, 0, ShipDate), 0) as MonthStartDate
			  from Archive.MailingHistory_CatRqst  
			  where CatalogAdcode not in (18156,32640)   
			  and Year(DATEADD(month, DATEDIFF(month, 0, ShipDate), 0)) = ' + Cast(@Year as Varchar(4)) + '
			  and DATEADD(month, DATEDIFF(month, 0, ShipDate), 0) <= DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0)
			  group by CustomerID,CatalogAdcode,DATEADD(month, DATEDIFF(month, 0, ShipDate), 0)
			  Union All
			 /*NCJFY*/			  
 			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, JFYMailDate), 0) as MonthStartDate
			  from Archive.MailingHistory_NCJFY  
			  where Adcode not in (18156,32640)   
			  and Year(DATEADD(month, DATEDIFF(month, 0, JFYMailDate), 0)) = ' + Cast(@Year as Varchar(4)) + '
			  and DATEADD(month, DATEDIFF(month, 0, JFYMailDate), 0) <= DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0)
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, JFYMailDate), 0)
			  Union All
			/*MailingHistory*/
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)  as MonthStartDate
			  from Archive.Mailinghistory' + Cast(@Year as Varchar(4)) + '
			  where AdCode not in (18156,32640)   
			  AND FlagHoldOut = 0
			  and Year(DATEADD(month, DATEDIFF(month, 0, StartDate), 0)) =  ' + Cast(@Year as Varchar(4)) + '
			  and DATEADD(month, DATEDIFF(month, 0, StartDate), 0) <= DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0)
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)'

			  Print @SQL

			  Exec (@SQL)


		   End

	If object_id('Staging.MC_TGC_MailingContact') is not null
		Begin 

			SELECT
			CustomerID, 
			MonthStartDate,
			sum(case when V.MD_PromotionType IN ('House Mailings: Catalog','House Mailings: Catalog No 2','House Mailings: HighSchool mailing','Institutional Mailing: Library Catalogs') then 1 else 0 end) TotalCatalogs,  
			sum(case when V.MD_PromotionType IN ('House Mailings: Catalog Reactivation') then 1 else 0 end) TotalCatalogReactivations,  
			sum(case when V.MD_PromotionType IN ('House Mailings: Deep Inactive Reactivation') then 1 else 0 end) TotalDeepInactives,  
			sum(case when V.MD_PromotionType IN ('House Mailings: Magalog', 'House Mailings: Magalog Reactivation') then 1 else 0 end) TotalMagalogs,  
			sum(case when V.MD_PromotionType IN ('House Mailings: Magnificent 7','House Mailings: Magnificent 7 Reactivation') then 1 else 0 end) TotalMag7s,  
			sum(case when V.MD_PromotionType IN ('House Mailings: Letter', 'House Mailings: Letter Reactivation') then 1 else 0 end) TotalLetters,  
			sum(case when V.MD_PromotionType IN ('House Mailings: Convertalog','House Mailings: Welcome Package') then 1 else 0 end) TotalConvertalogs,  
			sum(case when V.MD_PromotionType NOT IN (
												  'House Mailings: Catalog','House Mailings: Catalog No 2','House Mailings: HighSchool mailing','Institutional Mailing: Library Catalogs',
												  'House Mailings: Catalog Reactivation','House Mailings: Deep Inactive Reactivation','House Mailings: Magalog', 'House Mailings: Magalog Reactivation',
												  'House Mailings: Magnificent 7','House Mailings: Magnificent 7 Reactivation','House Mailings: Letter', 'House Mailings: Letter Reactivation',
												  'House Mailings: Convertalog','House Mailings: Welcome Package')
				  then 1 else 0 end) TotalOtherMailings,
			Count(T.Adcode) as TotalMailings,
			Getdate() as DMLastupdated
			Into #MC_TGC_MailingContact
			FROM Staging.MC_TGC_MailingContact T
			left Join mapping.vwAdcodesAll v
			on v.adcode = t.adcode
			group by  CustomerID,MonthStartDate


			delete M from Marketing.MC_TGC_MailingContact M
			join #MC_TGC_MailingContact T 
			on T.Customerid = M.Customerid and T.MonthStartDate = M.MonthStartDate


			Insert Into Marketing.MC_TGC_MailingContact (CustomerID,MonthStartDate,TotalCatalogs,TotalCatalogReactivations,TotalDeepInactives,TotalMagalogs,TotalMag7s,TotalLetters,TotalConvertalogs,TotalOtherMailings,TotalMailings)

			select CustomerID,MonthStartDate,TotalCatalogs,TotalCatalogReactivations,TotalDeepInactives,TotalMagalogs,TotalMag7s,TotalLetters,TotalConvertalogs,TotalOtherMailings,TotalMailings
			From #MC_TGC_MailingContact



		End


				 
/* need to add [Archive].[MailingHistory_NCJFY] for 2013 onwards  */
/* need to add [Archive].[MailingHistory_CatRqst] from 2014 Onwards */

End 

GO
