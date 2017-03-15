SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Staging].[eW_Yearly_BaseTableLoad]
	@StartDate Date,
	@YTDDate Date = null
AS
	declare 
    	@SQLStatement nvarchar(1000),
    	@CCSTbl varchar(100),
    	@CDCRTbl varchar(100),
    	@StartDateVar varchar(20)
    	
/*
	-- Preethi Ramanuam -- 8/20/2014 -- Update Demographic information from WD table instead of Experian table
*/    	
BEGIN
    set nocount on
    
    select @StartDateVar = CONVERT(varchar,@StartDate,112)
    
    set @CCSTbl = 'Archive.CampaignCustomerSignature' + @StartDateVar

    set @CDCRTbl = 'Archive.CustomerDynamicCourseRank' + @StartDateVar
    
    -- if current year, get today's date, else get today's date in the year of startdate
    DECLARE @YearDiff int
    select @YearDiff = YEAR(@Startdate) - YEAR(getdate())
    
    if YEAR(@StartDate) = YEAR(getdate())
		set @YTDDate = coalesce(dateadd(day,1,@YTDDate), cast(getdate() as Date))
    else 
		set @YTDDate = coalesce(dateadd(day,1,@YTDDate), dateadd(year, @YearDiff, cast(dateadd(day,1,getdate()) as Date)))

	print '@@YearDiff = ' + convert(varchar,@YearDiff)	
	print '@StartDate = ' + convert(varchar,@StartDate)		
	print '@@YTDDate = ' + convert(varchar,@YTDDate)		
    
    if object_id('Staging.eW_Yearly_Working') is not null drop table Staging.eW_Yearly_Working
    
    if object_id('Staging.eW_Yearly_CCS') is not null drop table Staging.eW_Yearly_CCS
    set @SQLStatement = 'select * into Staging.eW_Yearly_CCS from ' + @CCSTbl + ' (nolock)'    
	
	print @SQLStatement
	exec sp_executesql @SQLStatement
    
    if object_id('Staging.eW_Yearly_CDCR') is not null drop table Staging.eW_Yearly_CDCR
    set @SQLStatement = 'select * into Staging.eW_Yearly_CDCR from ' + @CDCRTbl + ' (nolock)'  
    print @SQLStatement  
	exec sp_executesql @SQLStatement 
 
	/* Load yearly base table */
	print 'Load yearly base table'
	
	SELECT  @StartDate as AsOfDate, 
		YEAR(@StartDate) as AsOfYear, 
		1 as AsOfMonth,
		case when a.Countrycode in ('US','USA') then 'US'
			when a.CountryCode in ('CA','GB','AU') then a.CountryCode
			else 'ROW'
		end as CountryCode,
		a.CustomerID, a.CustomerSegment, a.Frequency, a.NewSeg, a.Name,
		a.A12mf, a.FlagEmail as FlagEmailable, a.FlagEmailPref, a.FlagValidEmail,
		a.FlagMail, 
		a.State,
		convert(varchar(30),null) Region,
		-- Preethi Ramanuam -- 8/20/2014 -- Update Demographic information from WD table instead of Experian table
		--c.Gender, 
		--c.Education, 
		--c.HouseHoldIncomeBin,
		left(c.Gender,1) as Gender, 
		c.Education,
		case when c.IncomeDescription in ('1: $0-$14,999','2: $15,000 - $19,999',
									'3: $20,000 - $29,999','4: $30,000 - $39,999',
									'5: $40,000 - $49,999') then 'LessThan$50K'
			when c.IncomeDescription in ('6: $50,000 - $74,999') then '$50K-$74K'
			when c.IncomeDescription in ('7: $75,000 - $99,999','8: $100,000 - $124,999') then '$75K-$124K'
			when c.IncomeDescription in ('9: $125,000 - $149,999','10: $150,000 - $174,999',
											'11: $175,000 - $199,999','12: $200,000 - $249,000',
											'13: $250,000+') then '$125k+'
			else 'Unknown'
		End HouseHoldIncomeBin,
		DATEDIFF(month,c.DateOfBirth,@StartDate)/12 as Age,
		CONVERT(varchar(20),null) AgeBin,
		a.PreferredCategory2 as SubjectCategoryPref2,
		a.PreferredCategory as SubjectCategoryPref,
		convert(varchar(5), '') SubjectPref2_EOY,  -- Added on 9/18/2013 -- PR
		b.R3OrderSourcePref, b.R3FormatMediaPref, b.DSLPurchase, b.TenureDays,
		a.R3PurchWeb, a.FlagWebLTM18,
		eWGroup=
		case when a.FlagEmail=1 and b.R3OrderSourcePref='W' then 'e-W'
			when a.FlagEmail=1 and b.R3OrderSourcePref<>'W' then 'e-NW'
			when a.FlagEmail=0 and b.R3OrderSourcePref='W' then 'Ne-W'
			when a.FlagEmail=0 and b.R3OrderSourcePref<>'W' then 'Ne-NW'
		end,
		b.LTDPurchases, 
		CONVERT(int,0) as TTB,
		CONVERT(varchar(15),'') as TTB_Bin,
		b.DSLPurchase/30 as Recency, 
		LTDAvgOrderBin = 
		CASE WHEN b.LTDAvgOrd < 100 THEN '< than $100'
			WHEN b.LTDAvgOrd BETWEEN 100 AND 220 THEN 'Between $100 and $220'
			WHEN b.LTDAvgOrd > 220 THEN '> than $220'
		END,
		convert(varchar(20),'0-0 Months') as DSLPurchBin,
		case when b.TenureDays between 1 and 90 then '1-3 Months'
			when b.TenureDays between 91 and 180 then '4-6 Months'
			when b.TenureDays between 181 and 540 then '7-18 Months'
			when b.TenureDays between 541 and 1080 then '19-36 Months'
			when b.TenureDays between 1081 and 1800 then '37-60 Months'
			when b.TenureDays > 1800 then '61-1000 Months'
			else '0-0'
		end TenureBin,
		CONVERT(tinyint,0) FlagNearInactive, 
		CONVERT(tinyint,0) FlagPrEmailOrder, 
		CONVERT(tinyint,1) FlagEngagedCust,
		CONVERT(tinyint,0) FlagBoughtDigitlBfr, -- Added on 4/15/2013 -- PR
		CONVERT(varchar(50),'') SalesBinPriorYr, -- Added on 4/15/2013 -- PR
		CONVERT(Varchar(50),'') CourseCntBinPriorYr, -- Added on 7/10/2012 -- PR
		
		CONVERT(Int,null) IntlYear,
		CONVERT(Int,null) IntlMonth,
		CONVERT(Varchar(5),'') IntlSubjectPref,
		CONVERT(Varchar(2),'') IntlFormatMediaPref,
		CONVERT(Varchar(1),'') IntlOrderSource,
		CONVERT(Int,null) IntlPromotionTypeID,
		CONVERT(Varchar(50),'') IntlPromotionType,
		CONVERT(money,0) IntlPurchAmount,             -- PR added on 9/17/2013
		convert(varchar(50),'') IntlAvgOrderBin,      -- PR added on 9/17/2013
		CONVERT(tinyint,0) FlagPurchYTD,
		CONVERT(tinyint,0) FlagPurchNwCrsYTD,
		CONVERT(int,0) NwCrsNumsYTD,
		CONVERT(varchar(20),'') NwCrsBinYTD,
		CONVERT(money,0) as PurchAmountYTD,
		CONVERT(int,0) as PurchasesYTD,
		CONVERT(money,0) as CourseSalesYTD,	
		CONVERT(int,0) as UnitsPurchYTD,
		CONVERT(money,0) as PartsPurchYTD,
		CONVERT(money,0) as EmailContactsYTD,
		CONVERT(int,0) as MailContactsYTD,
		CONVERT(int,0) as EmailSalesYTD,
		CONVERT(int,0) as EmailOrdersYTD,
		CONVERT(int,0) as EmailUnitsYTD,
		CONVERT(int,0) as WebSalesYTD,
		CONVERT(int,0) as WebOrdersYTD,
		
		-- Add them in the main table..
		CONVERT(money,0) CatalogSalesYTD,
		CONVERT(int,0) CatalogOrdersYTD,
		CONVERT(money,0) MagalogSalesYTD,
		CONVERT(int,0) MagalogOrdersYTD,
		CONVERT(money,0) Mag7SalesYTD,
		CONVERT(int,0) Mag7OrdersYTD,
		CONVERT(money,0) MagazineSalesYTD,
		CONVERT(int,0) MagazineOrdersYTD,
		CONVERT(money,0) LetterSalesYTD,
		CONVERT(int,0) LetterOrdersYTD,
		CONVERT(money,0) MagbackSalesYTD,
		CONVERT(int,0) MagbackOrdersYTD,
		CONVERT(money,0) ReactivationSalesYTD,
		CONVERT(int,0) ReactivationOrdersYTD,
		CONVERT(money,0) EmailDLRSalesYTD,
		CONVERT(int,0) EmailDLROrdersYTD,
		CONVERT(money,0) EmailRevGenSalesYTD,
		CONVERT(int,0) EmailRevGenOrdersYTD,
		CONVERT(money,0) OtherSalesYTD,
		CONVERT(int,0) OtherOrdersYTD,
		
		CONVERT(money,0) CDSalesYTD,
		CONVERT(int,0) CDOrdersYTD,
		CONVERT(money,0) DVDSalesYTD,
		CONVERT(int,0) DVDOrdersYTD,
		CONVERT(money,0) VDLSalesYTD,
		CONVERT(int,0) VDLOrdersYTD,
		CONVERT(money,0) ADLSalesYTD,
		CONVERT(int,0) ADLOrdersYTD,
		CONVERT(money,0) TranscriptSalesYTD,
		CONVERT(int,0) TranscriptOrdersYTD,
		
		CONVERT(tinyint,0) FlagPurchMTD,  -- Added MTD on 3/18/2013 -- PR
		CONVERT(tinyint,0) FlagPurchNwCrsMTD,
		CONVERT(int,0) NwCrsNumsMTD,
		CONVERT(varchar(20),'') NwCrsBinMTD,
		CONVERT(money,0) as PurchAmountMTD,
		CONVERT(int,0) as PurchasesMTD,
		CONVERT(money,0) as CourseSalesMTD,	
		CONVERT(int,0) as UnitsPurchMTD,
		CONVERT(money,0) as PartsPurchMTD,
		CONVERT(money,0) as EmailContactsMTD,
		CONVERT(int,0) as MailContactsMTD,
		CONVERT(int,0) as EmailSalesMTD,
		CONVERT(int,0) as EmailOrdersMTD,
		CONVERT(int,0) as EmailUnitsMTD,
		CONVERT(int,0) as WebSalesMTD,
		CONVERT(int,0) as WebOrdersMTD,
		
		CONVERT(tinyint,0) FlagPurchFY,  -- Added Full Yr on 4/15/2013 -- PR
		/*CONVERT(tinyint,0) FlagPurchNwCrsFY,
		CONVERT(int,0) NwCrsNumsFY,
		CONVERT(varchar(20),'') NwCrsBinFY,*/
		CONVERT(money,0) as PurchAmountFY,
		CONVERT(int,0) as PurchasesFY,
		CONVERT(money,0) as CourseSalesFY,	
		CONVERT(int,0) as UnitsPurchFY,
		CONVERT(money,0) as PartsPurchFY,
		CONVERT(money,0) as EmailContactsFY,
		CONVERT(int,0) as MailContactsFY,
		CONVERT(int,0) as EmailSalesFY,
		CONVERT(int,0) as EmailOrdersFY,
		--CONVERT(int,0) as EmailUnitsFY,
		CONVERT(int,0) as WebSalesFY,
		CONVERT(int,0) as WebOrdersFY
	into Staging.eW_Yearly_Working	
	from Staging.eW_Yearly_CCS a left join
		Staging.eW_Yearly_CDCR b on convert(varchar,a.CustomerID) = b.CustomerID left join
		Mapping.CustomerOverlay_WD c on a.Customerid = c.CustomerID 
		-- Mapping.CustomerOverLay c on a.Customerid = c.CustomerID  -- Preethi Ramanuam -- 8/20/2014 -- Update Demographic information from WD table instead of Experian table
	where a.CustomerSegment in ('Active','Swamp','Inactive')
	and a.CountryCode in ('US','USA','GB','CA','AU')
	

	/* Update DSLPurchBin */
	print 'Update DSLPurchBin'
	
	UPDATE DMC
	SET DMC.DSLPurchBin = BD.DSLPurchBin
	FROM Staging.eW_Yearly_Working	 DMC, 
		MarketingCubes.dbo.BinDSLPurchases BD	
	WHERE DMC.DSLPurchase BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @StartDate
	
	--select DSLPurchBin, min(DSLPurchase), MAX(DSLPurchase), COUNT(customerid)
	--from Staging.eW_Yearly_Working	 
	--group by DSLPurchBin
	--order by 2

   /* load near inactive flag */
   print 'load near inactive flag'
	
   update Staging.eW_Yearly_Working
   set FlagNearInactive = 1
   where newseg in (13,14,15,6,7)

  
   --select newseg, name, a12mf, FlagNearInactive, COUNT(customerid)
   --from Staging.eW_Yearly_Working
   --group by newseg, name, a12mf, FlagNearInactive
   --order by newseg, name, a12mf, FlagNearInactive
   
	/* update Region */
	print 'update Region'
	
	update a
	set a.Region = isnull(b.Region,'None')
	from Staging.eW_Yearly_Working a join
		Mapping.DMRegion b on a.state = b.State	


	/* Update TTB info*/
	
	print 'Update TTB info'
	
	update Staging.eW_Yearly_Working 
	set TTB=
		case when LTDPurchases=1 then 0
		when LTDPurchases>1 and ((TenureDays-DSLPurchase)/30)/(LTDPurchases-1)<1 then 1
		when LTDPurchases>1 and ((TenureDays-DSLPurchase)/30)/(LTDPurchases-1)>=1 then ((TenureDays-DSLPurchase)/30)/(LTDPurchases-1)
		end;


	update Staging.eW_Yearly_Working 
	set TTB_Bin=
		case when TTB = 0 then 'ZZ: 0 Month'
			when TTB between 1 and 6 then 'A: 1-6 Months'
			when TTB between 7 and 12 then 'B: 7-12 Months'
			when TTB between 13 and 18 then 'C: 13-18 Months'
			when TTB between 19 and 24 then 'D: 19-24 Months'
			when TTB > 24 then 'Z: 24+ Months'
			else 'ZZ: 0 Month'				
		end;
	

	/* Update Agebin */
	print 'Update Agebin'
	
		UPDATE Staging.eW_Yearly_Working
		SET AgeBin = CASE WHEN Age < 35 then '34-'
						WHEN Age between 35 and 44 then '35-44'
						WHEN Age between 45 and 54 then '45-54'
						WHEN Age between 55 and 64 then '55-64'
						WHEN Age between 65 and 79 then '65-79'
						WHEN Age >= 80 then '80+'
						ELSE ''
						END	

		                    
	/* update initial value udpates */
	print 'update initial value udpates'
	
	update a
	set a.IntlYear = YEAR(b.IntlPurchaseDate),
		a.IntlMonth = month(b.IntlPurchaseDate),
		a.IntlSubjectPref = b.IntlSubjectPref,
		a.IntlFormatMediaPref = b.IntlFormatMediaPref,
		a.IntlOrderSource = b.IntlOrderSource,
		a.IntlPromotionTypeID = b.IntlPromotionTypeID,
		a.IntlPurchAmount = b.IntlPurchAmount
	from Staging.eW_Yearly_Working a join
		Marketing.DMCustomerStatic b on a.CustomerID = b.customerid
		

	update Staging.eW_Yearly_Working
		set IntlAvgOrderBin = 	CASE WHEN IntlPurchAmount > 0 and IntlPurchAmount <= 50 then '$0.01 - $50.00'
									WHEN IntlPurchAmount > 50 and IntlPurchAmount <= 75 then '$50.01 - $75.00'
									WHEN IntlPurchAmount > 75 and IntlPurchAmount <= 100 then '$75.01 - $100.00'
									WHEN IntlPurchAmount > 100 and IntlPurchAmount <= 150 then '$100.01 - $150.00'
									WHEN IntlPurchAmount > 150 then '$150.01 +'
								end

	update a
	set a.IntlPromotionType	= b.PromotionType
	from Staging.eW_Yearly_Working a join
		MarketingCubes..DimPromotionType b on a.intlpromotiontypeid = b.PromotionTypeID

	/*Update prior Year sales bin*/
   print 'Update prior Year sales bin'
	
    if object_id('staging.e_W_PriorYearSaleBin') is not null drop table staging.e_W_PriorYearSaleBin

	select @StartDate as AsOfDate, 
		YEAR(@StartDate) as AsOfYear,
		a.CustomerID, 
		isnull(sum(b.NetOrderAmount),0) SalesInPrYr,
		isnull(sum(b.TotalCourseQuantity),0) CoursesInPrYr
	into staging.e_W_PriorYearSaleBin
	from Staging.eW_Yearly_Working  a
	left join  Marketing.DMPurchaseOrders b
	on a.CustomerID=b.customerid
	and b.DateOrdered between DATEADD(year,-1,@StartDate) and @StartDate
	group by a.CustomerID
	

	--select * from staging.e_W_PriorYearSaleBin

	update a
	set SalesBinPriorYr=
			case when SalesInPrYr=0 then 'A: 2012Sales: = $0'
				when SalesInPrYr>0 and SalesInPrYr<=300 then 'B: 2012Sales: $0.01 - $300'
				when SalesInPrYr>300 and SalesInPrYr<=400 then 'C: 2012Sales: $300.01 - $400'
				when SalesInPrYr>400 and SalesInPrYr<=500 then 'D: 2012Sales: $400.01 - $500'
				when SalesInPrYr>500 and SalesInPrYr<=600 then 'E: 2012Sales: $500.01 - $600'
				when SalesInPrYr>600 and SalesInPrYr<=700 then 'F: 2012Sales: $600.01 - $700'
				when SalesInPrYr>700 and SalesInPrYr<=1000 then 'G: 2012Sales: $700.01 - $1000'
				when SalesInPrYr>1000 and SalesInPrYr<=1500 then 'H: 2012Sales: $1000.01 - $1500'
				when SalesInPrYr>1500  then 'I: 2012Sales: > $1500'
			END,
		CourseCntBinPriorYr = 
			case when CoursesInPrYr <= 0 then 'A: 0'
				when CoursesInPrYr =1 then 'B: 1'
				when CoursesInPrYr =2 then 'C: 2'
				when CoursesInPrYr =3 then 'D: 3'
				when CoursesInPrYr =4 then 'E: 4'
				when CoursesInPrYr in (5,6) then 'F: 5-6'
				when CoursesInPrYr in (7,8,9) then 'G: 7-9'
				when CoursesInPrYr in (10,11,12) then 'H: 10-12'
				when CoursesInPrYr > 12 and CoursesInPrYr <=20 then 'I: 13-20'
				when CoursesInPrYr > 20 then 'J: 21+'
			END 
	from Staging.eW_Yearly_Working a
	join staging.e_W_PriorYearSaleBin b
	on a.AsOfYear = b.asofyear
	and a.CustomerID=b.CustomerID


	/* UPDATE FlagBoughtDigitlBfr */
	print 'UPDATE FlagBoughtDigitlBfr'
	
	update a
	set a.FlagBoughtDigitlBfr = e.FlagBoughtDigitlBfr
	from Staging.eW_Yearly_Working a JOIN
		(select distinct CustomerID, 1 as FlagBoughtDigitlBfr  -- PR - 4/15/2013 -- added FlagBoughtDigitlBfr
		from Marketing.DMPurchaseOrderItems
		where DateOrdered <= @StartDate
		AND StockItemID like 'D[AV]%')e on a.CustomerID = e.CustomerID	
			

	-------------------------------------------------------------------------------		
		/* Load YTD Data*/	
		print 'Load YTD Data'
		
		/* Load PurchAmountYTD, PurchasesYTD*/
	 select asofyear, SUM(PurchAmountYTD) PurchAmountYTD, SUM(Purchasesytd) Purchasesytd,
  		SUM(CourseSalesYTD) CourseSalesYTD,
		SUM(UnitsPurchYTD) UnitsPurchYTD, SUM(PartsPurchYTD) PartsPurchYTD
	 from Staging.eW_Yearly_Working
	 group by asofyear   
	 
	     
		UPDATE TCD
			SET TCD.PurchAmountYTD = isnull(FinalSales,0),
				TCD.PurchasesYTD = isnull(CntOrders,0),
				TCD.FlagPurchYTD = 1
				FROM Staging.eW_Yearly_Working TCD INNER JOIN 
		(
			SELECT DPO.CustomerID, COUNT(DPO.OrderID) As CntOrders, 
				SUM(FinalSales) As FinalSales
				FROM Marketing.DMPurchaseOrders DPO 
				WHERE 	DPO.DateOrdered >= @StartDate AND DPO.DateOrdered < @YTDDate --GETDATE() -- Need this for YTD
				AND FinalSales between 5 and 1500
				GROUP BY DPO.CustomerID --order by 1
		) t ON TCD.CustomerID = T.CustomerID 		
		
		
		UPDATE TCD
			SET TCD.EmailSalesYTD = isnull(FinalSales,0),
				TCD.EmailOrdersYTD = isnull(CntOrders,0)
		FROM Staging.eW_Yearly_Working TCD INNER JOIN 
		(
			SELECT DPO.CustomerID, COUNT(DPO.OrderID) As CntOrders, 
				SUM(FinalSales) As FinalSales
				FROM Marketing.DMPurchaseOrders DPO 
				WHERE 	DPO.DateOrdered >= @StartDate AND DPO.DateOrdered < @YTDDate --GETDATE() -- Need this for YTD
				AND FinalSales between 5 and 1500
				AND FlagEmailOrder = 1
				GROUP BY DPO.CustomerID --order by 1
		) t ON TCD.CustomerID = T.CustomerID 		



		
		UPDATE TCD
			SET TCD.WebSalesYTD = isnull(FinalSales,0),
				TCD.WebOrdersYTD = isnull(CntOrders,0)
		FROM Staging.eW_Yearly_Working TCD INNER JOIN 
		(
			SELECT DPO.CustomerID, COUNT(DPO.OrderID) As CntOrders, 
				SUM(FinalSales) As FinalSales
				FROM Marketing.DMPurchaseOrders DPO 
				WHERE 	DPO.DateOrdered >= @StartDate AND DPO.DateOrdered < @YTDDate --GETDATE() -- Need this for YTD
				AND FinalSales between 5 and 1500
				AND OrderSource = 'W'
				GROUP BY DPO.CustomerID --order by 1
		) t ON TCD.CustomerID = T.CustomerID 	
			
			
		/* Add Total Parts and hours purchased in the subsequent month to the table*/
		UPDATE TCD
		SET TCD.CourseSalesYTD = ISNULL(cp.totalsales,0),
			TCD.PartsPurchYTD = isnull(CP.TotalCourseParts,0),
			TCD.UnitsPurchYTD = isnull(CP.TotalQuantity,0) /* added on 3/8/2011 - Preethi Ramanujam*/
		FROM Staging.eW_Yearly_Working TCD INNER JOIN
		(
    		SELECT dpo.CustomerID,
    			SUM(OI.TotalSales) TotalSales,
    			SUM(DMC.CourseParts * TotalQuantity) TotalCourseParts, 
				SUM(DMC.CourseHours * TotalQuantity) TotalCourseHours,
				SUM(TotalQuantity) TotalQuantity
			FROM Marketing.DMPurchaseOrders DPO 
			JOIN Marketing.DMPurchaseOrderItems OI ON dpo.OrderID = OI.OrderID JOIN
				Mapping.DMCourse DMC ON DMC.Courseid = OI.CourseID
			WHERE 
        		OI.StockItemID like '[PD][ACDVM]%'
        		and DPO.DateOrdered >= @StartDate 
				AND DPO.DateOrdered < @YTDDate --GETDATE()
		AND FinalSales between 5 and 1500 
			GROUP BY dpo.CustomerID)CP ON TCD.Customerid = CP.CustomerID
	   
	 select asofyear, 
		SUM(PurchAmountYTD) PurchAmountYTD, 
		SUM(Purchasesytd) Purchasesytd,
 		SUM(CourseSalesYTD) CourseSalesYTD,
		SUM(UnitsPurchYTD) UnitsPurchYTD, 
		SUM(PartsPurchYTD) PartsPurchYTD,
		sum(WebSalesYTD) WebSalesYTD,
		sum(WebOrdersYTD) WebOrdersYTD,
		sum(EmailSalesYTD) EmailSalesYTD,
		sum(EmailOrdersYTD) EmailOrdersYTD
	 from Staging.eW_Yearly_Working
	 group by asofyear   
	 
	 --------------------------------------------------------------------------------
		/* Load FY data */
		print 'Load FY data'
	
		
		/* Load PurchAmountFY, PurchasesFY*/
	 select asofyear, SUM(PurchAmountFY) PurchAmountFY, SUM(PurchasesFY) PurchasesFY,
  		SUM(CourseSalesFY) CourseSalesFY,
		SUM(UnitsPurchFY) UnitsPurchFY, SUM(PartsPurchFY) PartsPurchFY
	 from Staging.eW_Yearly_Working
	 group by asofyear   
	 
	     
		UPDATE TCD
			SET TCD.PurchAmountFY = isnull(FinalSales,0),
				TCD.PurchasesFY = isnull(CntOrders,0),
				TCD.FlagPurchFY = 1
				FROM Staging.eW_Yearly_Working TCD INNER JOIN 
		(
			SELECT DPO.CustomerID, COUNT(DPO.OrderID) As CntOrders, 
				SUM(FinalSales) As FinalSales
				FROM Marketing.DMPurchaseOrders DPO 
				WHERE 	DPO.DateOrdered >= @StartDate AND DPO.DateOrdered < DATEADD(year,1,@StartDate) -- Need this for FY
				AND FinalSales between 5 and 1500
				GROUP BY DPO.CustomerID --order by 1
		) t ON TCD.CustomerID = T.CustomerID 		
		
		UPDATE TCD
			SET TCD.EmailSalesFY = isnull(FinalSales,0),
				TCD.EmailOrdersFY = isnull(CntOrders,0)
		FROM Staging.eW_Yearly_Working TCD INNER JOIN 
		(
			SELECT DPO.CustomerID, COUNT(DPO.OrderID) As CntOrders, 
				SUM(FinalSales) As FinalSales
			FROM Marketing.DMPurchaseOrders DPO 
			WHERE 	DPO.DateOrdered >= @StartDate AND DPO.DateOrdered < DATEADD(year,1,@StartDate) -- Need this for FY
			AND FinalSales between 5 and 1500
			AND FlagEmailOrder = 1
			GROUP BY DPO.CustomerID --order by 1
		) t ON TCD.CustomerID = T.CustomerID 		



		
		UPDATE TCD
			SET TCD.WebSalesFY = isnull(FinalSales,0),
				TCD.WebOrdersFY = isnull(CntOrders,0)
		FROM Staging.eW_Yearly_Working TCD INNER JOIN 
		(
			SELECT DPO.CustomerID, COUNT(DPO.OrderID) As CntOrders, 
				SUM(FinalSales) As FinalSales
				FROM Marketing.DMPurchaseOrders DPO 
				WHERE 	DPO.DateOrdered >= @StartDate AND DPO.DateOrdered < DATEADD(year,1,@StartDate) -- Need this for FY
				AND FinalSales between 5 and 1500
				AND OrderSource = 'W'
				GROUP BY DPO.CustomerID --order by 1
		) t ON TCD.CustomerID = T.CustomerID 	
			
			
		/* Add Total Parts and hours purchased in the subsequent month to the table*/
		UPDATE TCD
		SET TCD.CourseSalesFY = ISNULL(cp.totalsales,0),
			TCD.PartsPurchFY = isnull(CP.TotalCourseParts,0),
			TCD.UnitsPurchFY = isnull(CP.TotalQuantity,0) /* added on 3/8/2011 - Preethi Ramanujam*/
		FROM Staging.eW_Yearly_Working TCD INNER JOIN
		(
    		SELECT dpo.CustomerID,
    			SUM(OI.TotalSales) TotalSales,
    			SUM(DMC.CourseParts * TotalQuantity) TotalCourseParts, 
				SUM(DMC.CourseHours * TotalQuantity) TotalCourseHours,
				SUM(TotalQuantity) TotalQuantity
			FROM Marketing.DMPurchaseOrders DPO 
			JOIN Marketing.DMPurchaseOrderItems OI ON dpo.OrderID = OI.OrderID JOIN
				Mapping.DMCourse DMC ON DMC.Courseid = OI.CourseID
			WHERE 
        		OI.StockItemID like '[PD][ACDVM]%'
        		and DPO.DateOrdered >= @StartDate 
				AND DPO.DateOrdered < DATEADD(year,1,@StartDate)
		AND FinalSales between 5 and 1500 
			GROUP BY dpo.CustomerID)CP ON TCD.Customerid = CP.CustomerID
	   
	 select asofyear, 
		SUM(PurchAmountFY) PurchAmountFY, 
		SUM(PurchasesFY) PurchasesFY,
 		SUM(CourseSalesFY) CourseSalesFY,
		SUM(UnitsPurchFY) UnitsPurchFY, 
		SUM(PartsPurchFY) PartsPurchFY,
		sum(WebSalesFY) WebSalesFY,
		sum(WebOrdersFY) WebOrdersFY,
		sum(EmailSalesFY) EmailSalesFY,
		sum(EmailOrdersFY) EmailOrdersFY
	 from Staging.eW_Yearly_Working
	 group by asofyear   
	----------------------------------------------------------------------------------------

	 /* Update Mail Contacts for FY */
	print 'Update Mail Contacts for FY'
	 
	 Declare @MHTable varchar(50)
	 
	 select @MHTable = 'archive.MailingHistory' + convert(varchar,YEAR(@StartDate))

    if object_id('Staging.eW_Yearly_MH') is not null drop table Staging.eW_Yearly_MH
    set @SQLStatement = 'select CustomerID,AdCode,NewSeg,Name,a12mf,Concatenated,FlagHoldOut,ComboID,SubjRank,PreferredCategory2,StartDate
						 into Staging.eW_Yearly_MH from ' + @MHTable + ' (nolock)'   +
						' where year(Startdate) = year(''' + convert(varchar,@StartDate,111) + ''')'
	print @SQLStatement  
	exec sp_executesql @SQLStatement    
   
    if object_id('Staging.eW_Yearly_MH_FY') is not null drop table Staging.eW_Yearly_MH_FY    
    select a.CustomerID, 
		COUNT(b.Adcode) TotalMails
	into Staging.eW_Yearly_MH_FY
	from Staging.eW_Yearly_Working a join
		Staging.eW_Yearly_MH b on a.customerid = b.CustomerID
	group by a.customerid
	  
	  
	 update a
	 set a.MailContactsFY = b.TotalMails
	 from Staging.eW_Yearly_Working a join
		Staging.eW_Yearly_MH_FY b on a.customerid = b.customerid


	/* Update Mail Contacts for YTD */
	print 'Update Mail Contacts for YTD'
	
	
	-- If YTD is for current year, use the same update table.
	 if object_id('Staging.eW_Yearly_MH_YTD') is not null drop table Staging.eW_Yearly_MH_YTD  
	 
	--if @YTDDate = CAST(getdate() as DATe)
	--	begin
	--		select *
	--		into Staging.eW_Yearly_MH_YTD
	--		from Staging.eW_Yearly_MH_FY
	--	end
	--else
	--	begin
			select a.CustomerID, 
				COUNT(b.Adcode) TotalMails
			into Staging.eW_Yearly_MH_YTD
			from Staging.eW_Yearly_Working a join
				Staging.eW_Yearly_MH b on a.customerid = b.CustomerID
			where b.startdate < @YTDDate		
			group by a.customerid
		--end
		
	 update a
	 set a.MailContactsYTD = b.TotalMails
	 from Staging.eW_Yearly_Working a join
		Staging.eW_Yearly_MH_YTD b on a.customerid = b.customerid	
 
	----------------------------------------------------------------------------------------

	 /* Update Email Contacts for FY */
	print 'Update Email Contacts for FY'
	 

    if object_id('Staging.eW_Yearly_EmH') is not null drop table Staging.eW_Yearly_EmH
    set @SQLStatement = 'select * into Staging.eW_Yearly_EmH from archive.EmailHistory (nolock)'   +
						' where year(Startdate) = year(''' + convert(varchar,@StartDate,111) + ''')'
	print @SQLStatement  
	exec sp_executesql @SQLStatement  
	
	delete from   Staging.eW_Yearly_EmH
	where flagHoldout = 1
   
    if object_id('Staging.eW_Yearly_EmH_FY') is not null drop table Staging.eW_Yearly_EmH_FY    
    select a.CustomerID, 
		COUNT(b.Adcode) TotalEmails
	into Staging.eW_Yearly_EmH_FY
	from Staging.eW_Yearly_Working a join
		Staging.eW_Yearly_EmH b on a.customerid = b.CustomerID
	group by a.customerid
	  
	  
	 update a
	 set a.EmailContactsFY = b.TotalEmails
	 from Staging.eW_Yearly_Working a join
		Staging.eW_Yearly_EmH_FY b on a.customerid = b.customerid


	/* Update Email Contacts for YTD */
	print 'Update Email Contacts for YTD'
	
	-- If YTD is for current year, use the same update table.
	 if object_id('Staging.eW_Yearly_EmH_YTD') is not null drop table Staging.eW_Yearly_EmH_YTD  
	 
	--if YEAR(@StartDate) = YEAR(getdate())
	--	begin
	--		select *
	--		into Staging.eW_Yearly_EmH_YTD
	--		from Staging.eW_Yearly_EmH_FY
	--	end
	--else
	--	begin
			select a.CustomerID, 
				COUNT(b.Adcode) TotalEmails
			into Staging.eW_Yearly_EmH_YTD
			from Staging.eW_Yearly_Working a join
				Staging.eW_Yearly_EmH b on a.customerid = b.CustomerID
			where b.startdate < @YTDDate		
			group by a.customerid
		--end
		
	 update a
	 set a.EmailContactsYTD = b.TotalEmails
	 from Staging.eW_Yearly_Working a join
	 	Staging.eW_Yearly_EmH_YTD b on a.customerid = b.customerid	

	/* Update FlagEngaged Flag as of beginning of the year */
	print 'Update FlagEngaged Flag as of beginning of the year'
	
	If YEAR(@StartDate) > 2011
		begin
			declare @NonEngTable varchar(100)
			
			set @NonEngTable = 'Archive.Email_NonEngaged_Customers_' + CONVERT(varchar,YEAR(@startdate))
		
			set @SQLStatement = ' update a
			 set a.FlagEngagedCust = 0
			 from Staging.eW_Yearly_Working a join ' +
				@NonEngTable + ' b on a.customerid = b.CustomerID'
				
			print @SQLStatement  
			exec sp_executesql @SQLStatement  			
				
		end			


	-- Add additional sales column by promotion
	-- PR 2/12/2013
		
	-- update catalog sales
	print 'update catalog sales'
	
	 update a
	 set a.CatalogSalesYTD = b.Sales,
		a.CatalogOrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(OrderID) Orders,
				SUM(NetOrderAmount) Sales
		from Marketing.DMPurchaseOrders
		where PromotionType = 607
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID


	-- update Magalog sales
	print 'update Magalog sales'
	
	 update a
	 set a.MagalogSalesYTD = b.Sales,
		a.MagalogOrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(OrderID) Orders,
				SUM(NetOrderAmount) Sales
		from Marketing.DMPurchaseOrders
		where PromotionType = 802
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID

	 
	-- update Mag7 sales
	print 'update Mag7 sales'
	
	 update a
	 set a.Mag7SalesYTD = b.Sales,
		a.Mag7OrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(OrderID) Orders,
				SUM(NetOrderAmount) Sales
		from Marketing.DMPurchaseOrders
		where PromotionType = 116
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID

	 
	 
	-- update Magazine sales
	print 'update Magazine sales'
	
	 update a
	 set a.MagazineSalesYTD = b.Sales,
		a.MagazineOrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(OrderID) Orders,
				SUM(NetOrderAmount) Sales
		from Marketing.DMPurchaseOrders
		where PromotionType = 1854
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID


	 
	-- update Letter sales
	print 'update Letter sales'
	
	 update a
	 set a.LetterSalesYTD = b.Sales,
		a.LetterOrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(OrderID) Orders,
				SUM(NetOrderAmount) Sales
		from Marketing.DMPurchaseOrders
		where PromotionType = 108
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID
		

	 
	-- update Reactivation sales
	print 'update Reactivation sales'
	
	 update a
	 set a.ReactivationSalesYTD = b.Sales,
		a.ReactivationOrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(OrderID) Orders,
				SUM(NetOrderAmount) Sales
		from Marketing.DMPurchaseOrders
		where PromotionType = 606
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID

	 
	 
	-- update MagBack sales
	print 'update MagBack sales'
	
	 update a
	 set a.MagBackSalesYTD = b.Sales,
		a.MagBackOrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(OrderID) Orders,
				SUM(NetOrderAmount) Sales
		from Marketing.DMPurchaseOrders
		where PromotionType = 2628
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID

	 
	-- update EmailDLR sales
	print 'update EmailDLR sales'
	
	 update a
	 set a.EmailDLRSalesYTD = b.Sales,
		a.EmailDLROrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(OrderID) Orders,
				SUM(NetOrderAmount) Sales
		from Marketing.DMPurchaseOrders
		where PromotionType = 1180
		and CatalogCode in (select CatalogCode from superstardw..MktCatalogCodes
							where CampaignID = 163)
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID



	 update Staging.eW_Yearly_Working
	 set EmailRevGenSalesYTD = EmailSalesYTD - EmailDLRSalesYTD,
		EmailRevGenOrdersYTD = EmailOrdersYTD - EmailDLROrdersYTD
	 
	 update Staging.eW_Yearly_Working
	set 	OtherSalesYTD = PurchAmountYTD - (EmailSalesYTD + CatalogSalesYTD + MagalogSalesYTD + Mag7SalesYTD + MagazineSalesYTD + LetterSalesYTD + MagbackSalesYTD + ReactivationSalesYTD),
		OtherOrdersYTD = 	PurchasesYTD - (EmailOrdersYTD + CatalogOrdersYTD + MagalogOrdersYTD + Mag7OrdersYTD +  MagazineOrdersYTD + LetterOrdersYTD + MagbackOrdersYTD + ReactivationOrdersYTD)
		
	 
		
	-- Add additional sales column by Format
	-- PR 2/13/2013

		
		
	-- update CD sales
	print 'update CD sales'
	
	 update a
	 set a.CDSalesYTD = b.Sales,
		a.CDOrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(distinct OrderID) Orders,
				SUM(TotalSales) Sales
		from Marketing.DMPurchaseOrderItems
		where left(StockItemID,2) = 'PC'
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID

	-- update DVD sales
	print 'update DVD sales'
	
	 update a
	 set a.DVDSalesYTD = b.Sales,
		a.DVDOrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(distinct OrderID) Orders,
				SUM(TotalSales) Sales
		from Marketing.DMPurchaseOrderItems
		where left(StockItemID,2) = 'PD'
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID

	-- update VDL sales
	print 'update VDL sales'
	
	 update a
	 set a.VDLSalesYTD = b.Sales,
		a.VDLOrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(distinct OrderID) Orders,
				SUM(TotalSales) Sales
		from Marketing.DMPurchaseOrderItems
		where left(StockItemID,2) = 'DV'
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID


	-- update ADL sales
	print 'update ADL sales'
	
	 update a
	 set a.ADLSalesYTD = b.Sales,
		a.ADLOrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(distinct OrderID) Orders,
				SUM(TotalSales) Sales
		from Marketing.DMPurchaseOrderItems
		where left(StockItemID,2) = 'DA'
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID

	-- update Transcript sales
	print 'update Transcript sales'
	
	 update a
	 set a.TranscriptSalesYTD = b.Sales,
		a.TranscriptOrdersYTD = b.Orders
	 -- select count(a.customerid)
	 from Staging.eW_Yearly_Working a join
		(select CustomerID, 
				COUNT(distinct OrderID) Orders,
				SUM(TotalSales) Sales
		from Marketing.DMPurchaseOrderItems
		where StockItemID like '[pd]t%'
		and DateOrdered between @StartDate and @YTDDate
		group by Customerid)b on a.customerid = b.CustomerID
		
	delete a
	from Marketing.eW_YTD_FY_YOY_BaseTable a 
	where AsOfDate = @StartDate
	
	insert into Marketing.eW_YTD_FY_YOY_BaseTable
	select * from Staging.eW_Yearly_Working
    
    --if object_id('Staging.eW_Yearly_CCS') is not null drop table Staging.eW_Yearly_CCS   
    --if object_id('Staging.eW_Yearly_CDCR') is not null drop table Staging.eW_Yearly_CDCR 
    --if object_id('Staging.eW_Yearly_MH') is not null drop table Staging.eW_Yearly_MH
    
END
GO
