SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[MaxEmailOpenDateUpdate]   @Load varchar(20) = 'Update'
as              
              
Begin    

	declare @startdate date

	if @Load <> 'Load' 
			select @Startdate = dateadd(month,-1,cast(getdate() as date))
		else  
			select @Startdate = '1/1/2001'

	select 'StartDate = ', @startdate, 'LoadType = ', @Load

	/***************** Temp table *************************/

	If object_id ('staging.MaxEmailOpenDateTemp') is not null
	drop table staging.MaxEmailOpenDateTemp          
              
	select a.email as EmailAddress, b.dax_customer_id as CustomerID, max(a.datestamp) MaxOpenDate
	into staging.MaxEmailOpenDateTemp
	from Archive.SM_TRACKING_LOG a left join
		MagentoImports..Email_Customer_Information b on a.EMAIL = b.subscriber_email
	where a.ttype in ('open')
	and a.DATESTAMP >= @Startdate
	group by a.EMAIL, b.dax_customer_id
              

	delete a
	from archive.MaxEmailOpenDate a join
		staging.MaxEmailOpenDateTemp b on a.EmailAddress = b.EmailAddress
							

	insert into archive.MaxEmailOpenDate
	select distinct * from staging.MaxEmailOpenDateTemp


End 

GO
