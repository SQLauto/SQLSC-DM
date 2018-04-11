SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_MC_TGC_EMailContacts] @MonthStartDate Date = Null,@Year int = null
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
				
			If object_id('Staging.MC_TGC_EMailContact') is not null
				Begin 
				Drop table Staging.MC_TGC_EMailContact
				End 

			 
			/*EMailHistory*/
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0) as MonthStartDate
			  into Staging.MC_TGC_EMailContact
			  from Archive.EmailhistoryCurrentYear 
			  where FlagHoldOut = 0
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
			  	If object_id(''Staging.MC_TGC_EMailContact'') is not null
				Begin 
				Drop table Staging.MC_TGC_EMailContact
				End 

 
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0) as MonthStartDate
			  into Staging.MC_TGC_EMailContact
			  from Archive.EMailhistory' + Cast(@Year@MonthStartDate as Varchar(4)) + '
			  where FlagHoldOut = 0
			  and DATEADD(month, DATEDIFF(month, 0, StartDate), 0) = ''' + Cast(@MonthStartDate as Varchar(10)) + '''  
			  and Year(DATEADD(month, DATEDIFF(month, 0, StartDate), 0)) =  ' + Cast(@Year@MonthStartDate as Varchar(4)) + '
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)'

			  Print @SQL

			  Exec (@SQL)

		   End

	If @Year is Not null
		   Begin

			  set @SQL = '
			  	If object_id(''Staging.MC_TGC_EMailContact'') is not null
				Begin 
				Drop table Staging.MC_TGC_EMailContact
				End 

			  /* EMailHistory*/
			 
			  select CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)  as MonthStartDate
			  into Staging.MC_TGC_EMailContact
			  from Archive.EMailHistory' + Cast(@Year as Varchar(4)) + '
			  where FlagHoldOut = 0
			  and Year(DATEADD(month, DATEDIFF(month, 0, StartDate), 0)) =  ' + Cast(@Year as Varchar(4)) + '
			  and DATEADD(month, DATEDIFF(month, 0, StartDate), 0) <= DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0)
			  group by CustomerID,Adcode,DATEADD(month, DATEDIFF(month, 0, StartDate), 0)'

			  Print @SQL

			  Exec (@SQL)


		   End

	If object_id('Staging.MC_TGC_EMailContact') is not null
		Begin 

			SELECT
			CustomerID, 
			MonthStartDate,
			Count(T.Adcode) as TotalEMails,
			Getdate() as DMLastupdated
			Into #MC_TGC_EMailContact
			FROM Staging.MC_TGC_EMailContact T
			group by  CustomerID,MonthStartDate


			delete M from Marketing.MC_TGC_EMailContact M
			join #MC_TGC_EMailContact T 
			on T.Customerid = M.Customerid and T.MonthStartDate = M.MonthStartDate


			Insert Into Marketing.MC_TGC_EMailContact (CustomerID,MonthStartDate,TotalEMails,DMLastupdated)

			select  CustomerID,MonthStartDate,TotalEMails,DMLastupdated
			From #MC_TGC_EMailContact



		End



End 

GO
