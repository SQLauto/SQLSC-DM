SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[SP_update_3month_Engaged_status]
as

Begin

--Get the last three month data

		select *
		into #temp
		from  DataWarehouse.Archive.[SM_TRACKING_LOG] (nolock)
		where datestamp >= DATEADD(MONTH, -3,convert(datetime,convert(varchar,getdate(),101)))
		and ttype in ('open')

		drop table DataWarehouse.Marketing.Email_Engaged3Month

		select email, TType, MAX(DateStamp) MaxDateStamp,
			sum(case when ttype = 'open' then 1 else 0 end) as Opens_Last3Months,
			GETDATE() TableCreateDate
		into DataWarehouse.Marketing.Email_Engaged3Month
		from #temp
		where datestamp >= DATEADD(MONTH, -3,convert(datetime,convert(varchar,getdate(),101)))
		and ttype in ('open')
		group by email, Ttype


--select 	MIN(maxDatestamp) MinDateStamp, 
--	MAX(maxdatestamp) MaxDateStamp, 
--	COUNT(email) TotalCount
--from DataWarehouse.Marketing.Email_Engaged3Month


-- Now add New customers to this table so they can get the 'Engaged Emails'
-- if they are not already engaged.
		insert into DataWarehouse.Marketing.Email_Engaged3Month
		select a.*
		from (select distinct Emailaddress,  'New' Ttype, CustomerSince, 0 as Opens_Last3Months, GETDATE() TableCreateDate
				from DataWarehouse.Marketing.CampaignCustomerSignature (nolock)
				where CustomerSince >= DATEADD(MONTH, -4,convert(datetime,convert(varchar,getdate(),101)))
				and FlagEmail = 1)A LEFT JOIN
				DataWarehouse.Marketing.Email_Engaged3Month b on A.EmailAddress = b.email
		where b.email is null


		/*clean up*/
		delete from DataWarehouse.Marketing.Email_Engaged3Month
		where email like '~%'


		-- Create Non Engaged table
		drop table DataWarehouse.Marketing.Email_NonEngaged3Month

		/*All emailable customers except the last 3 month engaged*/
		select a.*
		INTO DataWarehouse.Marketing.Email_NonEngaged3Month
		from (select *
			from DataWarehouse.Marketing.CampaignCustomerSignature (nolock)
			where FlagEmail = 1
			and CountryCode = 'US')a 
			left join DataWarehouse.Marketing.Email_Engaged3Month b (nolock)
			on a.EmailAddress = b.email
		where b.email is null


drop table #temp


End

GO
