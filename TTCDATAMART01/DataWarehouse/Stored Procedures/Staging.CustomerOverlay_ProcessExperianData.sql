SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[CustomerOverlay_ProcessExperianData]
AS
BEGIN
	set nocount on
    
	if object_id('Staging.TempCustomerOverlay') is not null drop table Staging.TempCustomerOverlay
    
	-- drop duplicates if any
    ;with cteDuplicates(CustomerID, RowNum) as
    (
    	select 
        	CustomerID,
            row_number() over(partition by CustomerID order by CustomerID)
		from Staging.TempCustomerOverLay_RawData (nolock)
    )
    delete
    from cteDuplicates
    where RowNum > 1
    
	-- Some QC..
    select EstHouseholdIncomeV4, COUNT(CustomerID) CustCount
    from  Staging.TempCustomerOverLay_RawData 
    group by EstHouseholdIncomeV4
    order by 1
      
    select Education_Individual1, EstHouseholdIncomeV4, COUNT(CustomerID) CustCount
    from  Staging.TempCustomerOverLay_RawData 
    group by Education_Individual1, EstHouseholdIncomeV4
    order by 1,2
     
    select combinedAge, COUNT(CustomerID) CustCount
    from Staging.TempCustomerOverLay_RawData 
    group by combinedAge
    order by 1
     
    select Education_Individual1, COUNT(CustomerID) CustCount
    from  Staging.TempCustomerOverLay_RawData 
    group by Education_Individual1
    order by 1
      
    select BirthDateCCYYMM, COUNT(CustomerID) CustCount
    from  Staging.TempCustomerOverLay_RawData 
    where combinedAge like 'I%'
    group by BirthDateCCYYMM
    order by 1

      
    select [POCAge0_3V3], COUNT(CustomerID) CustCount
    from  Staging.TempCustomerOverLay_RawData 
    group by [POCAge0_3V3]
    order by 1   
    		
    select [POCAge4_6V3], COUNT(CustomerID) CustCount
    from  Staging.TempCustomerOverLay_RawData 
    group by [POCAge4_6V3]
    order by 1 
    		
    select [POCAge13_15V3], COUNT(CustomerID) CustCount
    from  Staging.TempCustomerOverLay_RawData 
    group by [POCAge13_15V3]
    order by 1 
     
    select [POCAge16_18V3], COUNT(CustomerID) CustCount
    from  Staging.TempCustomerOverLay_RawData 
    group by [POCAge16_18V3]
    order by 1    
     
    select Gender, COUNT(CustomerID) CustCount
    from  Staging.TempCustomerOverLay_RawData 
    group by Gender
    order by 1 
     
    select birthDateCCYYMM, CombinedAge, COUNT(customerid)
    from Staging.TempCustomerOverLay_RawData 
    where combinedage = ''
    group by birthDateCCYYMM, CombinedAge

    select distinct customerid from Staging.TempCustomerOverLay_RawData
    order by 1
    
    
	 select CONVERT(int,CustomerID) CustomerID, Gender,
	BirthDateCCYYMM as BirthDate_CCYYMM, 
	case when len(BirthDateCCYYMM) > 4  then 
							convert(int,LEFT(BirthDateCCYYMM,4))
		else null end as BirthYear,
	case when len(BirthDateCCYYMM) > 4 then 
			convert(int,RIGHT(BirthDateCCYYMM,2))
		else null
	end as BirthMonth,
	case when LEFT(BirthDateCCYYMM,4) > 0 then
		convert(datetime,convert(varchar,case when len(BirthDateCCYYMM) > 4 
									then RIGHT(BirthDateCCYYMM,2)
									else '1'
							end + '/1/' + LEFT(BirthDateCCYYMM,4),101)) 
	else null
	end DateOfBirth, CombinedAge, 
	case when left(CombinedAge,1) = 'I' then 'Estimated'
		when LEFT(combinedAge,1) = 'E' then 'Exact'
		else 'Unknown'
	end FlagAgeExctEst,
	convert(int,right(CombinedAge,2)) ExperianAge,
	a.EstHouseholdIncomeV4, 
	ISNULL(b.HouseholdIncomeBin,'Unknown') HouseHoldIncomeBin,
	ISNULL(b.HouseholdIncomeRange,'Unknown') HouseHoldIncomeRange,
	a.Education_Individual1, 
	c.Education, c.EducationConfidence,
	convert(varchar(5),[POC0_3YearsOldConfirm]) as POC0to3Confirm, 
	convert(varchar(5),[POC0_3YEARSOLDCODE])    as POC0to3Code, 
	convert(varchar(5),[POC4_6YearsOldConfirm]) as POC4to6Confirm, 
	convert(varchar(5),[POC4_6YearsOldCode])    as POC4to6Code, 
	convert(varchar(5),[POC7_9YearsOldConfirm]) as POC7to9Confirm, 
	convert(varchar(5),[POC7_9YEARSOLDCODE])    as POC7to9Code, 
	convert(varchar(5),[POC10_12YRSOldConfirm]) as POC10to12Confirm, 
	convert(varchar(5),[POC10_12YRSOLDCODE])    as POC10to12Code, 
	convert(varchar(5),[POC13_18YRSOLDCONFIRM]) as POC13to18Confirm, 
	convert(varchar(5),[POC13_18YRSOLDCODE])    as POC13to18Code,
	POCAge0_3V3, POCAge4_6V3, POCAge7_9V3, POCAge10_12V3, 
	POCAge13_15V3, POCAge16_18V3, 
	TotalEnhancementMatchType, DateFromExperian,
	GETDATE() as DateUpdated,
	CONVERT(datetime,'') IntlPurchaseDate,
	CONVERT(int,'') IntlPurchaseYear,
	Convert(int,'') IntlPurchaseMonth,
	CONVERT(int,'') IntlPurchaseAge,
	CONVERT(varchar(20),'') IntlPurchaseAgeBin,
	CONVERT(tinyint,0) FlagIntlHSByr,
	CONVERT(nvarchar(20),null) IntlPurchaseOrderID
    into Staging.TempCustomerOverLay
    from Staging.TempCustomerOverLay_RawData a left join
        Mapping.IncomeLookupTable b on isnull(a.EstHouseholdIncomeV4,'') = b.Est_Household_Income_V4 left join
        Mapping.EducationLookupTable c on ISNULL(a.Education_Individual1,'') = c.EDUCATION_INDIVIDUAL_1

    -- if the age is estimated with combined age starting from I, then calculate
    select distinct  RIGHT(CombinedAge,2), 
        DATEADD(YEAR,(experianAge*-1),DateFromExperian),
        year(DATEADD(YEAR,(experianAge*-1),DateFromExperian))	
    from Staging.TempCustomerOverLay
    where FlagAgeExctEst = 'Estimated'

    update Staging.TempCustomerOverLay
    set BirthYear = year(DATEADD(YEAR,(experianAge*-1),DateFromExperian)),
        BirthDate_CCYYMM = year(DATEADD(YEAR,(experianAge*-1),DateFromExperian))
    where FlagAgeExctEst = 'Estimated'
    -- 

    update Staging.TempCustomerOverLay
    set DateOfBirth = case when LEFT(BirthDate_CCYYMM,4) > 0 then
            convert(datetime,convert(varchar,case when len(BirthDate_CCYYMM) > 4 
                                        then RIGHT(BirthDate_CCYYMM,2)
                                        else '1'
                                end + '/1/' + LEFT(BirthDate_CCYYMM,4),101)) 
        else null
        end 
    where FlagAgeExctEst = 'Estimated'
	-- 

    select birthyear, dateofbirth, COUNT(customerid)
    from Staging.TempCustomerOverLay
    where FlagAgeExctEst = 'Estimated'
    group by birthyear, dateofbirth
    order by 1,2

    update Staging.TempCustomerOverLay 
    set birthyear = year(dateofbirth),
        birthmonth = month(dateofbirth)
    -- select * from Datawarehouse.Staging.TempCustomerOverLay 
    where birthyear is null	
    -- 

    -- Update Initial purchase information from CustomerStatic Table
    update a
    set a.IntlPurchaseDate = b.IntlPurchaseDate,
        a.IntlPurchaseYear = year(b.IntlPurchaseDate),
        a.IntlPurchaseMonth = MONTH(b.IntlPurchaseDate)
    from Staging.TempCustomerOverLay a join
        Marketing.DMCustomerStatic b (nolock) on a.customerid = b.CustomerID
    -- 
    
    -- Update Age at the time of initial purchase
    update Staging.TempCustomerOverLay 
    set IntlPurchaseAge = DATEDIFF(DAY,DateOfBirth,IntlPurchaseDate)/365,
        IntlPurchaseAgeBin = case when DATEDIFF(DAY,DateOfBirth,IntlPurchaseDate)/365 <= 35 then '35 or less' 	
            when DATEDIFF(DAY,DateOfBirth,IntlPurchaseDate)/365 between 36 and 45 then '36-45'
             when DATEDIFF(DAY,DateOfBirth,IntlPurchaseDate)/365 between 46 and 55 then '46-55'
             when DATEDIFF(DAY,DateOfBirth,IntlPurchaseDate)/365 between 56 and 64 then '56-64'
             when DATEDIFF(DAY,DateOfBirth,IntlPurchaseDate)/365 between 65 and 75 then '65-75'
             when DATEDIFF(DAY,DateOfBirth,IntlPurchaseDate)/365 >= 76 then '76+'
             else 'Unknown'
        end 		
    -- 

    -- Add Flag if they purchased HS course.
    update a
    set a.IntlPurchaseOrderID = b.IntlPurchaseOrderID
    from Staging.TempCustomerOverLay a join
        Marketing.DMCustomerStatic b (nolock) on a.customerid = b.CustomerID

    update a
    set a.FlagIntlHSByr = 1
    from Staging.TempCustomerOverLay a join
        (select distinct a.CustomerID
        from Marketing.DMPurchaseOrderItems a (nolock) join
            Staging.TempCustomerOverLay b (nolock) on a.OrderID = b.IntlPurchaseOrderID join
            mapping.dmcourse c (nolock) on a.CourseID = c.CourseID
        where c.SubjectCategory = 'HS')b on a.customerid = b.CustomerID
    	
    select FlagIntlHSByr, COUNT(customerid)
    from Staging.TempCustomerOverLay 
    group by FlagIntlHSByr
    
    -- QC
    select BirthYear, IntlPurchaseYear, IntlPurchaseAgeBin,
        MIN(IntlPurchaseAge) Min_IntlPurchaseAge,
        max(IntlPurchaseAge) Max_IntlPurchaseAge,
        AVG(IntlPurchaseAge) Avg_IntlPurchaseAge,
        MIN(ExperianAge) Min_ExperianAge,
        max(ExperianAge) Max_ExperianAge,
        avg(ExperianAge) Avg_ExperianAge	
    from Staging.TempCustomerOverLay 
    group by  BirthYear, IntlPurchaseYear, IntlPurchaseAgeBin
    		
    select * from Mapping.CustomerOverLay
    
    insert into Mapping.CustomerOverLay
    select a.*, getdate()
    from Staging.TempCustomerOverLay a (nolock) left outer join
        Mapping.CustomerOverLay b (nolock) on a.customerid = b.CustomerID
    where b.CustomerID is null

    -- No more dupes!!
    select customerid
    from Mapping.CustomerOverLay
    group by CustomerID
    having COUNT(customerid) > 1

    select * from Mapping.CustomerOverLay

    select updatedate, COUNT(customerid)
    from Mapping.CustomerOverLay
    group by UpdateDate
    order by 1 desc

	if object_id('Staging.TempCustomerOverlay') is not null drop table Staging.TempCustomerOverlay
END
GO
