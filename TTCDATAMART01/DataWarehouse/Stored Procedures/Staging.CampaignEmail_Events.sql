SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CampaignEmail_Events]
	@AdCode int = 50407,
    @Month int = 0
as
	declare 
    	@FinalTableName varchar(200),
        @StartDate varchar(10),
        @SQLCommand nVARCHAR(1000),
        @SubjectLine varchar(100),
        @FirstMonth varchar(10),
        @SecondMonth varchar(10) 
begin
	--set nocount on
    
  	if object_id('Staging.TempEventsEmailableCustomers') is not null drop table Staging.TempEventsEmailableCustomers
    if object_id('Staging.TempEventsCandidates') is not null drop table Staging.TempEventsCandidates
    if object_id('Staging.TempEventsEmail') is not null drop table Staging.TempEventsEmail
    
	if @Month = 0 select @Month = month(getdate())
	set @FirstMonth = 'July' --datename(mm, cast(@Month + 1 as varchar(2)) + '/01/2000')
	set @SecondMonth = 'August' --datename(mm, cast(@Month + 2 as varchar(2)) + '/01/2000')
    
 --      set @Month = 12
   --     Set @FirstMonth = 'January'
    --    Set @SecondMonth = 'February'
    
--     set @SubjectLine = '##Cityname## Cultural Events in ' + @FirstMonth + ' and ' + @SecondMonth + ' from The Teaching Company' -- Changed to The Great Courses based on Joe's input - 4/24/2012
    set @SubjectLine = '##Cityname## Cultural Events in ' + @FirstMonth + ' and ' + @SecondMonth + ' from The Great Courses' 
        
    print '@month = ' + convert(varchar,@month)
    print '@FirstMonth = ' + convert(varchar,@FirstMonth)
    print '@SecondMonth = ' + convert(varchar,@SecondMonth)
    print '@SubjectLine = ' + convert(varchar,@SubjectLine)
 
   select 
    	@StartDate  = convert(varchar, a.StartDate, 112)
	from Mapping.vwAdcodesAll a   
    where a.AdCode = @AdCode     

    if isnull(@StartDate,'') = ''
		set @StartDate  = convert(varchar, GETDATE(), 112)
		
    print '@StartDate: ' + @StartDate

	set @FinalTableName = 'Ecampaigns.dbo.Email' + @StartDate + '_Offers_Events' + @FirstMonth + @SecondMonth

    print '@FinalTableName: ' + @FinalTableName

    
    print 'Step 1: get emailable customers'
    SELECT 
        c.PostalCode, 
        c.City,
        left(c.PostalCode, 5) AS Zip5, 
        c.CustomerID, 
        c.[State], 
        c.EmailAddress, 
        c.CountryCode, 
        c2.CountryName,
        c.FirstName,
        c.LastName,
        c.ComboID,
        c.PreferredCategory2,
        c.FlagEmail,
        c.State as Region,
        case 
			when isnull(c.PreferredCategory, '') in ('', 'EC', 'HS', 'PR', 'FW') then 'SC'
			when c.PreferredCategory = 'AH' then 'MH'
			else c.PreferredCategory
        end as PreferredCategory,
        c.CustomerSegmentNew 
    INTO Staging.TempEventsEmailableCustomers
    FROM Marketing.CampaignCustomerSignature c (nolock)
    left join Mapping.SHPlkCountry c2 (nolock) on c.CountryCode = c2.CountryCode
    where 
    	c.PublicLibrary = 0 
        and c.FlagEmail = 1

    delete t
    from Staging.TempEventsEmailableCustomers t
    where t.CustomerID not in (select ec.CustomerID from Staging.vwEmailableCustomers ec (nolock))
    
    print 'Step 2: get MSA candidates, PMSA candidates and CMSA/PMSA candidates'
    select
    	t.CustomerID,
        t.Zip5,
        t.[State],
        t.City,
        msa.MSA as MSAPMSACMSA,
        em.EventCity,
        em.CodeType,
        cast(null as int) as AdCode,
        cast(null as varchar(5)) as EventCityCode
	into Staging.TempEventsCandidates        
    from Staging.TempEventsEmailableCustomers t (nolock)
    join Mapping.EventsZipCodesMSA msa (nolock) on msa.ZipCode = t.Zip5
    join Mapping.EventsMaster em (nolock) on em.Code = msa.MSA
    union all
    select
    	t.CustomerID,
        t.Zip5,
        t.[State],        
        t.City,        
        msa.PMSA as MSAPMSACMSA,
        em.EventCity,
        em.CodeType,
        cast(null as int) as AdCode,
        cast(null as varchar(5)) as EventCityCode        
    from Staging.TempEventsEmailableCustomers t (nolock)
    join Mapping.EventsZipCodesMSA msa (nolock) on msa.ZipCode = t.Zip5
    join Mapping.EventsMaster em (nolock) on em.Code = msa.PMSA
    union all
    select
    	t.CustomerID,
        t.Zip5,
        t.[State],        
        t.City,        
        cmsa.CMSA as MSAPMSACMSA,
        em.EventCity,
        em.CodeType,
        cast(null as int) as AdCode,
        cast(null as varchar(5)) as EventCityCode        
    from Staging.TempEventsEmailableCustomers t (nolock)
    join Mapping.EventsZipCodesMSA msa (nolock) on msa.ZipCode = t.Zip5
	join Mapping.EventsMSAPMSA cmsa (nolock) on cmsa.MSA_PMSA = msa.PMSA   
    join Mapping.EventsMaster em (nolock) on em.Code = cmsa.CMSA
    
	print 'Step 3: delete outliers'
    ;with cteOutliers(CountOfCustomerID, EventCity, [State]) as
    (
        select 
            count(t.CustomerID) as CountOfCustomerID,
            t.EventCity,
            t.[State]
        from Staging.TempEventsCandidates t (nolock)
        group by t.EventCity, t.[State]
        having count(t.CustomerID) < 10
	)
    delete t
    from Staging.TempEventsCandidates t
    join cteOutliers o (nolock) on t.EventCity = o.EventCity and t.[State] = o.[State]
    
    print 'Step 4: set AdCode and EventCityCode for candidates'
    update t set
    	t.AdCode = c.AdCode,
        t.EventCityCode = c.EventCityCode
	from Staging.TempEventsCandidates t
    join Staging.EventCityAdCode c (nolock) on t.EventCity = c.EventCity
    
    delete t
    from Staging.TempEventsCandidates t
    where isnull(t.AdCode, 0) = 0

	print 'Step 5: combine emailable customers and candidates information'     
	select 
    	cus.CustomerID,
        cus.FirstName,
        cus.LastName,
        cus.EmailAddress,
        cus.Region,
	    1 as CourseID,
      	1 AS [Rank],
      	@AdCode AS Adcode,
        cus.[State],
        can.EventCity,
        can.EventCityCode, 
		@SubjectLine AS SubjectLine,
		'EmailEvents' + cast(year(getdate()) as varchar(4)) + '_' + cast(@AdCode as varchar(5)) as ECampaignID,        
        cus.ComboID,
        cus.PreferredCategory2,
        cus.FlagEmail,
        cus.PreferredCategory,
        cus.CustomerSegmentNew
	into Staging.TempEventsEmail    	
    from Staging.TempEventsEmailableCustomers cus (nolock)
    join Staging.TempEventsCandidates can (nolock) on cus.CustomerID = can.CustomerID
    
    print 'done inserting'
    
 
    print 'Step 6: populate final table ' + @FinalTableName
    
    if object_id(@FinalTableName) is not null 
    begin
		set @SQLCommand = 'drop table ' + @FinalTableName
		exec sp_executesql @SQLCommand
    end
    
    set @SQLCommand = 'select * into ' + @FinalTableName + ' from Staging.TempEventsEmail'
	exec sp_executesql @SQLCommand

	if object_id('Staging.TempEventsEmailableCustomers') is not null drop table Staging.TempEventsEmailableCustomers
    if object_id('Staging.TempEventsCandidates') is not null drop table Staging.TempEventsCandidates    
    if object_id('Staging.TempEventsEmail') is not null drop table Staging.TempEventsEmail    
end
GO
