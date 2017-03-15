SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Email_Enagament_and_NonEngagement_Quarterly] @Date date = null,@Debug int = 0
as
Declare @SQL nVARCHAR(4000),@StringDate varchar(10)

/*
To Create Qtrly Engagement and Non Engagement tables with 3 months prior from @date 

1) Pass the Qtr start Date as input. Defaulted to run on the 1st day of every Qtr.   

2) Calculates and creates Engagement and Non Engagement tables based of date provided or defaulted.

3) Calculates to current date to prior 3 months. 
	Ex: if you pass input date '10/01/2015'
		Then it would create Engagement/NonEngagement Tables with 20151001
		and have data from '07/01/2015' to '10/01/2015'.
4) 	@Debug =  1, Will provide execute SQL Script but will not create the tables.
*/

If @Date is null
Begin 
set @Date = DATEADD(MONTH, -3,convert(date,convert(varchar,GETDATE(),101))) 
End


set @StringDate = convert(varchar(8),@Date,112) 

if datepart(d,@Date) = 1 and datepart(m,@Date) in (1,4,7,10) /* Start of Every Qtr */
Begin

select DATEADD(MONTH, -3,convert(date,convert(varchar,@Date,101))) Date3MonthsAgo, @Date as DateProvided


set @SQL = '
			select *
			into #temp
			from Lstmgr..SM_Tracking_Log
			where datestamp between DATEADD(MONTH, -3,convert(date,convert(varchar,''' + cast(@Date as varchar(10)) + ''',101))) and ''' + cast(@Date as varchar(10)) + '''
			and ttype in (''open'')

			select convert(varchar(10),Ttype) Ttype, 
				MIN(Datestamp) MinDateStamp, 
				MAX(datestamp) MaxDateStamp, 
				COUNT(distinct email) Counts_UniqEmails,
				COUNT(email) Counts_Total
			from #temp
			group by convert(varchar(10),Ttype)

			if object_id (''archive.Email_Engaged3Month'+ @StringDate + ''') is NOT NULL
			Begin
			DROP TABLE archive.Email_Engaged3Month' + @StringDate + '
			End
			
			select email, TType, MAX(DateStamp) MaxDateStamp,
			sum(case when ttype = ''open'' then 1 else 0 end) as Opens_Last3Months,
			GETDATE() TableCreateDate
			into DataWarehouse.archive.Email_Engaged3Month' + @StringDate + '
			from #temp
			where ttype in (''open'')
			group by email, Ttype
			
			select 	MIN(maxDatestamp) MinDateStamp, 
			MAX(maxdatestamp) MaxDateStamp, 
			COUNT(email) TotalCount
			from DataWarehouse.Archive.Email_Engaged3Month' + @StringDate + '
			
			print ''Now add New customers to this table so they can get the Engaged Emails, if they are not already engaged.''
			
			insert into DataWarehouse.Archive.Email_Engaged3Month' + @StringDate + '
			select a.*
			from (select distinct Emailaddress,  ''New'' Ttype, CustomerSince, 0 as Opens_Last3Months, GETDATE() TableCreateDate
			from DataWarehouse.Archive.CampaignCustomerSignature' + @StringDate + '
			where CustomerSince >= DATEADD(MONTH, -4,convert(datetime,convert(varchar,''' + cast(@Date as varchar(10)) + ''',101)))
			and FlagEmail = 1)A LEFT JOIN
			DataWarehouse.Archive.Email_Engaged3Month' + @StringDate + ' b on A.EmailAddress = b.email
			where b.email is null
			
			Print ''Deleting emails like ~%''
			
			delete from DataWarehouse.Archive.Email_Engaged3Month' + @StringDate + '
			where email like ''~%''
			
			if object_id (''Archive.Email_NonEngaged_Customers_'+ @StringDate + ''') is NOT NULL
			Begin
			DROP TABLE Archive.Email_NonEngaged_Customers_' + @StringDate + '
			Print '' DROP TABLE Archive.Email_NonEngaged_Customers_'+ @StringDate + '''
			End

			select a.*
			INTO DataWarehouse.Archive.Email_NonEngaged_Customers_' + @StringDate + '
			from (select *
			from DataWarehouse.Archive.CampaignCustomerSignature' + @StringDate + '
			where FlagEmail = 1
			and CountryCode = ''US'')a left join
			DataWarehouse.Archive.Email_Engaged3Month' + @StringDate + ' b on a.EmailAddress = b.email
			where b.email is null
 
			'
			
Print (@SQL)

if @Debug = 0
Begin
Exec (@SQL)
END

End
GO
