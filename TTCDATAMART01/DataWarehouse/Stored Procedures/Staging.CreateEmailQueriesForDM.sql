SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CreateEmailQueriesForDM] @EmailID varchar(50)
AS
BEGIN
    set nocount on
    
/* Preethi Ramanujam 	12/12/2017
Creates queries for an emailID

*/

/* If no date is provided, then Sunday of the week it is run is taken*/

	IF @EmailID is null
	BEGIN
		PRINT 'Please provide emailID'
		return
   	END

	declare @Qry varchar(8000)--, @EmailID varchar(50)
	
	declare @PrspectGroup varchar(20)

	select @PrspectGroup = segmentgroup
	from mapping.email_adcode
	where emailid = @EmailID
	and SegmentGroup = 'Prospects'

	
	declare @CountryCode varchar(20)

	select @Countrycode = Countrycode
	from mapping.email_adcode
	where emailid = @EmailID

	-- Step 1
	-- get count by adcode
	set @Qry = 'select a.adcode, b.adcodename, b.catalogcode,a.Catalogname,a.CountryCode , count(distinct a.Emailaddress) EmailaddressCount, count(distinct a.customerid) CustCount 
					from datawarehouse.staging.' + @EmailID + 
					' a left outer join 
						DataWarehouse.Mapping.vwAdcodesAll b on a.adcode = b.adcode  
						group by a.adcode, b.adcodename, b.catalogcode  ,a.Catalogname,a.CountryCode 
						order by 1 '

	print @Qry
	print ''
	print ''

	--exec (@Qry)

	
	-- Step 2
	-- get top 10 *
	
	set @Qry = 'select top 10 * from lstmgr..' + @EmailID + '_NEW_Active' 
	print @Qry

	if @EmailID like '%_US_%' 
		begin	
			set @Qry = 'select top 10 * from lstmgr..' + @EmailID + '_NEW_SNI'
			print @Qry
		end
						

	if @PrspectGroup = 'Prospecgts'
		begin	
			set @Qry = 'select top 10 * from lstmgr..' + @EmailID + '_PRSPCT'
			print @Qry
		end

	print ''
	print ''

			
	-- Step 3
	-- Get Pref counts
	
	set @Qry = 'select PreferredCategory, count(*) from lstmgr..' + @EmailID + '_NEW_Active group by PreferredCategory order by 1' 
	print @Qry



	if @EmailID like '%_US_%' 
		begin	
			set @Qry = 'select PreferredCategory, count(*) from lstmgr..' + @EmailID + '_NEW_SNI group by PreferredCategory order by 1' 
			print @Qry
		end
				

	if @PrspectGroup = 'Prospecgts'
		begin	
			set @Qry = 'select PreferredCategory, count(*) from lstmgr..' + @EmailID + '_PRSPCT group by PreferredCategory order by 1' 
			print @Qry
		end

	print ''
	print ''


	-- Step 4
	-- Get Pref counts
	

	if @EmailID like '%_DP_%' or @EmailID like '%_TP_%'
		begin
			set @Qry = 'update lstmgr..' + @EmailID + '_NEW_Active set PreferredCategory = PreferredCategory + '''''
			print @Qry

		
			if @EmailID like '%_US_%' 
				begin	
					set @Qry = 'update lstmgr..' + @EmailID + '_NEW_SNI set PreferredCategory = PreferredCategory + '''''
					print @Qry
				end
				

			if @PrspectGroup = 'Prospecgts'
				begin	
					set @Qry = 'update lstmgr..' + @EmailID + '_PRSPCT set PreferredCategory = PreferredCategory + '''''
					print @Qry
				end
		end
	else 
		begin
			set @Qry = 'Exec Sp_EmailPull_LandingPageUpdate @emailid = ''' + @EmailID + '_NEW_Active''' 
			print @Qry
		end

	print ''
	print ''
	


	-- Step 5
	-- Get Pref counts
	
	set @Qry = 'select PreferredCategory, count(*) from lstmgr..' + @EmailID + '_NEW_Active group by PreferredCategory order by 1' 
	print @Qry

	
	if @EmailID like '%_US_%' 
		begin	
			set @Qry = 'select PreferredCategory, count(*) from lstmgr..' + @EmailID + '_NEW_SNI group by PreferredCategory order by 1' 
			print @Qry
		end

	if @PrspectGroup = 'Prospecgts'
		begin	
			set @Qry = 'select PreferredCategory, count(*) from lstmgr..' + @EmailID + '_PRSPCT group by PreferredCategory order by 1' 
			print @Qry
		end

	print ''
	print ''


END
GO
