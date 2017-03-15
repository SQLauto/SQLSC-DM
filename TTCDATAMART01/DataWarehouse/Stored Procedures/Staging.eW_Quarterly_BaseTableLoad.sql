SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Staging].[eW_Quarterly_BaseTableLoad]
	@QTRStartDate Date,
	@QTREndDate Date = null
/*
--Name: [Staging].[eW_QTR_BaseTableLoad]
--Purpose: Created to analyse quarterly cohort data
--Parameters: @QTRStartDate - Should be 1st of the quarter you want to analyze
--			@QTREndDate - Should be 1st of the next quarter or if it is left blank, it is calculated within the procedure.
--Update Inforamtion: 
--		New			Preethi Ramanujam			8/5/2014
--
*/	
AS
	declare 
    	@SQLStatement nvarchar(1000),
    	@CCSTbl varchar(100),
    	@CDCRTbl varchar(100),
    	@QTRStartDateVar varchar(20),
    	@Quarter varchar(2)
BEGIN
    set nocount on

	Declare  @StringNextQtrDate varchar(20) 
	set @StringNextQtrDate = CONVERT(varchar,dateadd(Q,1,@QTRStartDate),112)
    
    select @QTRStartDateVar = CONVERT(varchar,@QTRStartDate,112)
    
    set @CCSTbl = 'Archive.CampaignCustomerSignature' + @QTRStartDateVar

    set @CDCRTbl = 'Archive.CustomerDynamicCourseRank' + @QTRStartDateVar
    
    -- if current year, get today's date, else get today's date in the year of startdate
    DECLARE @YearDiff int
    select @YearDiff = YEAR(@QTRStartDate) - YEAR(getdate())
    
	set @QTREndDate = coalesce(@QTREndDate, dateadd(month,3,@QTRStartDate))

	print '@@YearDiff = ' + convert(varchar,@YearDiff)	
	print '@QTRStartDate = ' + convert(varchar,@QTRStartDate)		
	print '@@QTREndDate = ' + convert(varchar,@QTREndDate)	
	
	select @Quarter = case when month(@QTRStartDate) =	1 then 'Q1'
							when month(@QTRStartDate) = 4 then 'Q2'
							when month(@QTRStartDate) = 7 then 'Q3'
							when month(@QTRStartDate) = 10 then 'Q4'
						end
    
    if object_id('Staging.eW_Quarterly_Working') is not null drop table Staging.eW_Quarterly_Working
    
    if object_id('Staging.eW_Quarterly_CCS') is not null drop table Staging.eW_Quarterly_CCS
    set @SQLStatement = 'select * into Staging.eW_Quarterly_CCS from ' + @CCSTbl + ' (nolock)'    
	
	print @SQLStatement
	exec sp_executesql @SQLStatement
    
    if object_id('Staging.eW_Quarterly_CDCR') is not null drop table Staging.eW_Quarterly_CDCR
    set @SQLStatement = 'select * into Staging.eW_Quarterly_CDCR from ' + @CDCRTbl + ' (nolock)'  
    print @SQLStatement  
	exec sp_executesql @SQLStatement 
 
	/* Load yearly base table */
	print 'Load yearly base table'
	
	SELECT  @QTRStartDate as AsOfDate, 
		YEAR(@QTRStartDate) as AsOfYear, 
		@Quarter as AsOfQuarter,

		/* Customer Segments and Regions */
		case when a.Countrycode in ('US','USA') then 'US'
			when a.CountryCode in ('CA','GB','AU') then a.CountryCode
			else 'ROW'
		end as CountryCode,
		a.CustomerID, a.CustomerSegment, a.Frequency, a.NewSeg, a.Name,
		a.A12mf, a.CustomerSegment2, a.CustomerSegmentFnl,
		a.FlagEmail as FlagEmailable, a.FlagEmailPref, a.FlagValidEmail,
		a.FlagMail, 
		a.State,
		convert(varchar(30),null) Region,

		/* Customer Demographics */
		c.Gender, 
		case when c.IncomeDescription in ('1: $0-$14,999','2: $15,000 - $19,999',
									'3: $20,000 - $29,999','4: $30,000 - $39,999',
									'5: $40,000 - $49,999') then 'LessThan$50K'
			when c.IncomeDescription in ('6: $50,000 - $74,999') then '$50K-$74K'
			when c.IncomeDescription in ('7: $75,000 - $99,999','8: $100,000 - $124,999') then '$75K-$124K'
			when c.IncomeDescription in ('9: $125,000 - $149,999','10: $150,000 - $174,999',
											'11: $175,000 - $199,999','12: $200,000 - $249,000',
											'13: $250,000+') 
							then '$125k+'
			else 'Unknown'
		End HouseHoldIncomeBin,
		case when c.Education in ('3: Some College') then 'Some College'
			when c.Education in ('4: College') then 'Bachelor Degree'		
			when c.Education in ('5: Graduate School') then 'Graduate Degree'
			when c.Education in ('1: Some High School or Less','2: High School')
					then 'High School Diploma or Less'
					else 'Unknown'
		End EducationBin,
		DATEDIFF(month,c.DateOfBirth,@QTRStartDate)/12 as Age,
		CONVERT(varchar(20),null) AgeBin,
		
		/* Customer LTD and Preference Variables */		
		a.PreferredCategory2 as SubjectCategoryPref2,
		b.R3OrderSourcePref, b.R3FormatMediaPref, b.DSLPurchase, b.TenureDays,
		a.R3PurchWeb, 
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
		LTDAvgOrderBin2 = 
		CASE WHEN b.LTDAvgOrd > 0 and b.LTDAvgOrd <= 50 then '$0.01 - $50.00'
			WHEN b.LTDAvgOrd > 50 and b.LTDAvgOrd <= 75 then '$50.01 - $75.00'
			WHEN b.LTDAvgOrd > 75 and b.LTDAvgOrd <= 100 then '$75.01 - $100.00'
			WHEN b.LTDAvgOrd > 100 and b.LTDAvgOrd <= 150 then '$100.01 - $150.00'
			WHEN b.LTDAvgOrd > 150 then '$150.01 +'
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
		CONVERT(tinyint,0) FlagBoughtDigitlBfr, 
		CONVERT(varchar(50),'') SalesBinPr12Mnth, 
		CONVERT(Varchar(50),'') CourseCntBinPr12Mnth, 
		
		/* Initial purchase variables */
		CONVERT(Int,null) IntlYear,
		CONVERT(Int,null) IntlMonth,
		CONVERT(Varchar(5),'') IntlSubjectPref,
		CONVERT(Varchar(2),'') IntlFormatMediaPref,
		CONVERT(Varchar(1),'') IntlOrderSource,
		CONVERT(Int,null) IntlAdcode,
		CONVERT(Int,null) IntlPromotionTypeID,
		CONVERT(Varchar(50),'') IntlPromotionType,
		CONVERT(Varchar(50),'') IntlMD_Audience,
		CONVERT(Int,null) IntlMD_ChannelID,
		CONVERT(Varchar(50),'') IntlMD_Channel,
		CONVERT(Int,null) IntlMD_PromotionTypeID,
		CONVERT(Varchar(100),'') IntlMD_PromotionType,
		CONVERT(Int,null) IntlMD_CampaignID,
		CONVERT(Varchar(100),'') IntlMD_Campaign,
		CONVERT(Varchar(50),'') IntlMD_PriceType,
		CONVERT(money,0) IntlPurchAmount,             
		convert(varchar(50),'') IntlAvgOrderBin,     
		
		/* Quarterly variables and Measures */
		CONVERT(tinyint,0) FlagPurchQTR,
		CONVERT(tinyint,0) FlagPurchNwCrsQTR,
		CONVERT(int,0) NwCrsNumsQTR,
		CONVERT(varchar(20),'') NwCrsBinQTR,
		CONVERT(money,0) as PurchAmountQTR,
		CONVERT(int,0) as PurchasesQTR,
		CONVERT(money,0) as CourseSalesQTR,	
		CONVERT(int,0) as UnitsPurchQTR,
		CONVERT(money,0) as PartsPurchQTR,
		CONVERT(money,0) as EmailContactsQTR,
		CONVERT(int,0) as MailContactsQTR,
		CONVERT(int,0) as EmailSalesQTR,
		CONVERT(int,0) as EmailOrdersQTR,
		CONVERT(int,0) as EmailUnitsQTR,
		CONVERT(int,0) as WebSalesQTR,
		CONVERT(int,0) as WebOrdersQTR
	into Staging.eW_Quarterly_Working	
	from Staging.eW_Quarterly_CCS a left join
		Staging.eW_Quarterly_CDCR b on convert(varchar,a.CustomerID) = b.CustomerID left join
		Mapping.CustomerOverlay_WD c on a.Customerid = c.CustomerID 
	where a.CustomerSegment in ('Active','Swamp','Inactive')
	and a.CountryCode in ('US','USA','GB','CA','AU')
	
	/* Update DSLPurchBin */
	print 'Update DSLPurchBin'
	
	UPDATE DMC
	SET DMC.DSLPurchBin = BD.DSLPurchBin
	FROM Staging.eW_Quarterly_Working	 DMC, 
		MarketingCubes.dbo.BinDSLPurchases BD	
	WHERE DMC.DSLPurchase BETWEEN BD.MinLevel AND BD.MaxLevel
	AND DMC.AsOfDate = @QTRStartDate
	
	--select DSLPurchBin, min(DSLPurchase), MAX(DSLPurchase), COUNT(customerid)
	--from Staging.eW_Quarterly_Working	 
	--group by DSLPurchBin
	--order by 2

   /* load near inactive flag */
   print 'load near inactive flag'
	
   update Staging.eW_Quarterly_Working
   set FlagNearInactive = 1
   where newseg in (13,14,15,6,7)

  
   --select newseg, name, a12mf, FlagNearInactive, COUNT(customerid)
   --from Staging.eW_Quarterly_Working
   --group by newseg, name, a12mf, FlagNearInactive
   --order by newseg, name, a12mf, FlagNearInactive
   
	/* update Region */
	print 'update Region'
	
	update a
	set a.Region = isnull(b.Region,'None')
	from Staging.eW_Quarterly_Working a join
		Mapping.DMRegion b on a.state = b.State	


	/* Update TTB info*/
	
	print 'Update TTB info'
	
	update Staging.eW_Quarterly_Working 
	set TTB=
		case when LTDPurchases=1 then 0
		when LTDPurchases>1 and ((TenureDays-DSLPurchase)/30)/(LTDPurchases-1)<1 then 1
		when LTDPurchases>1 and ((TenureDays-DSLPurchase)/30)/(LTDPurchases-1)>=1 then ((TenureDays-DSLPurchase)/30)/(LTDPurchases-1)
		end;


	update Staging.eW_Quarterly_Working 
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
	
		UPDATE Staging.eW_Quarterly_Working
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
		a.IntlAdcode = b.IntlPurchaseAdCode,
		a.IntlPromotionTypeID = b.IntlPromotionTypeID,
		a.IntlPurchAmount = b.IntlPurchAmount
	from Staging.eW_Quarterly_Working a join
		Marketing.DMCustomerStatic b on a.CustomerID = b.customerid
		

	print 'update IntlAvgOrderBin'
	update Staging.eW_Quarterly_Working
		set IntlAvgOrderBin = 	CASE WHEN IntlPurchAmount > 0 and IntlPurchAmount <= 50 then '$0.01 - $50.00'
									WHEN IntlPurchAmount > 50 and IntlPurchAmount <= 75 then '$50.01 - $75.00'
									WHEN IntlPurchAmount > 75 and IntlPurchAmount <= 100 then '$75.01 - $100.00'
									WHEN IntlPurchAmount > 100 and IntlPurchAmount <= 150 then '$100.01 - $150.00'
									WHEN IntlPurchAmount > 150 then '$150.01 +'
								end

	
	print 'update IntlPromotionType'
	update a
	set a.IntlPromotionType	= b.PromotionType
	from Staging.eW_Quarterly_Working a join
		MarketingCubes..DimPromotionType b on a.intlpromotiontypeid = b.PromotionTypeID
	
	print 'update Intl MDs'
	update a
	set a.IntlMD_Audience = b.MD_Audience,
		a.IntlMD_ChannelID = b.ChannelID,
		a.IntlMD_Channel = b.MD_Channel,
		a.IntlMD_PromotionTypeID = b.MD_PromotionTypeID,
		a.IntlMD_PromotionType = b.MD_PromotionType,
		a.IntlMD_CampaignID = b.MD_CampaignID,
		a.IntlMD_Campaign = b.MD_CampaignName,
		a.IntlMD_PriceType = b.MD_PriceType
	from Staging.eW_Quarterly_Working a join
		Mapping.vwAdcodesAll b on a.IntlAdcode = b.AdCode


	/*Update prior 12 month sales bin*/
   print 'Update prior Year sales bin'
	
    if object_id('staging.e_W_PriorYearSaleBin') is not null drop table staging.e_W_PriorYearSaleBin

	select @QTRStartDate as AsOfDate, 
		YEAR(@QTRStartDate) as AsOfYear,
		a.CustomerID, 
		isnull(sum(b.NetOrderAmount),0) SalesInPrYr,
		isnull(sum(b.TotalCourseQuantity),0) CoursesInPrYr
	into staging.e_W_PriorYearSaleBin
	from Staging.eW_Quarterly_Working  a
	left join  Marketing.DMPurchaseOrders b
	on a.CustomerID=b.customerid
	and b.DateOrdered between DATEADD(year,-1,@QTRStartDate) and @QTRStartDate
	group by a.CustomerID
	

	--select * from staging.e_W_PriorYearSaleBin

	update a
	set SalesBinPr12Mnth=
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
		CourseCntBinPr12Mnth = 
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
	from Staging.eW_Quarterly_Working a
	join staging.e_W_PriorYearSaleBin b
	on a.AsOfYear = b.asofyear
	and a.CustomerID=b.CustomerID


	/* UPDATE FlagBoughtDigitlBfr */
	print 'UPDATE FlagBoughtDigitlBfr'
	
	update a
	set a.FlagBoughtDigitlBfr = e.FlagBoughtDigitlBfr
	from Staging.eW_Quarterly_Working a JOIN
		(select distinct CustomerID, 1 as FlagBoughtDigitlBfr  -- PR - 4/15/2013 -- added FlagBoughtDigitlBfr
		from Marketing.DMPurchaseOrderItems
		where DateOrdered <= @QTRStartDate
		AND StockItemID like 'D[AV]%')e on a.CustomerID = e.CustomerID	
			

	-------------------------------------------------------------------------------		
		/* Load QTR Data*/	
		print 'Load QTR Data'
		
		/* Load PurchAmountQTR, PurchasesQTR*/
	 select asofyear, SUM(PurchAmountQTR) PurchAmountQTR, SUM(PurchasesQTR) PurchasesQTR,
  		SUM(CourseSalesQTR) CourseSalesQTR,
		SUM(UnitsPurchQTR) UnitsPurchQTR, SUM(PartsPurchQTR) PartsPurchQTR
	 from Staging.eW_Quarterly_Working
	 group by asofyear   
	 
	     
		UPDATE TCD
			SET TCD.PurchAmountQTR = isnull(FinalSales,0),
				TCD.PurchasesQTR = isnull(CntOrders,0),
				TCD.FlagPurchQTR = 1
				FROM Staging.eW_Quarterly_Working TCD INNER JOIN 
		(
			SELECT DPO.CustomerID, COUNT(DPO.OrderID) As CntOrders, 
				SUM(FinalSales) As FinalSales
				FROM Marketing.DMPurchaseOrders DPO 
				WHERE 	DPO.DateOrdered >= @QTRStartDate 
				AND DPO.DateOrdered < @QTREndDate 
				AND FinalSales between 5 and 1500
				GROUP BY DPO.CustomerID 
		) t ON TCD.CustomerID = T.CustomerID 		
		
		
		UPDATE TCD
			SET TCD.EmailSalesQTR = isnull(FinalSales,0),
				TCD.EmailOrdersQTR = isnull(CntOrders,0)
		FROM Staging.eW_Quarterly_Working TCD INNER JOIN 
		(
			SELECT DPO.CustomerID, COUNT(DPO.OrderID) As CntOrders, 
				SUM(FinalSales) As FinalSales
				FROM Marketing.DMPurchaseOrders DPO 
				WHERE 	DPO.DateOrdered >= @QTRStartDate 
				AND DPO.DateOrdered < @QTREndDate 
				AND FinalSales between 5 and 1500
				AND FlagEmailOrder = 1
				GROUP BY DPO.CustomerID
		) t ON TCD.CustomerID = T.CustomerID 		



		
		UPDATE TCD
			SET TCD.WebSalesQTR = isnull(FinalSales,0),
				TCD.WebOrdersQTR = isnull(CntOrders,0)
		FROM Staging.eW_Quarterly_Working TCD INNER JOIN 
		(
			SELECT DPO.CustomerID, COUNT(DPO.OrderID) As CntOrders, 
				SUM(FinalSales) As FinalSales
				FROM Marketing.DMPurchaseOrders DPO 
				WHERE 	DPO.DateOrdered >= @QTRStartDate 
				AND DPO.DateOrdered < @QTREndDate 
				AND FinalSales between 5 and 1500
				AND OrderSource = 'W'
				GROUP BY DPO.CustomerID 
		) t ON TCD.CustomerID = T.CustomerID 	
			
			
		/* Add Total Parts and hours purchased in the subsequent month to the table*/
		UPDATE TCD
		SET TCD.CourseSalesQTR = ISNULL(cp.totalsales,0),
			TCD.PartsPurchQTR = isnull(CP.TotalCourseParts,0),
			TCD.UnitsPurchQTR = isnull(CP.TotalQuantity,0) 
		FROM Staging.eW_Quarterly_Working TCD INNER JOIN
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
        		and DPO.DateOrdered >= @QTRStartDate 
				AND DPO.DateOrdered < @QTREndDate 
		AND FinalSales between 5 and 1500 
			GROUP BY dpo.CustomerID)CP ON TCD.Customerid = CP.CustomerID
	   
	 select asofyear, 
		SUM(PurchAmountQTR) PurchAmountQTR, 
		SUM(PurchasesQTR) PurchasesQTR,
 		SUM(CourseSalesQTR) CourseSalesQTR,
		SUM(UnitsPurchQTR) UnitsPurchQTR, 
		SUM(PartsPurchQTR) PartsPurchQTR,
		sum(WebSalesQTR) WebSalesQTR,
		sum(WebOrdersQTR) WebOrdersQTR,
		sum(EmailSalesQTR) EmailSalesQTR,
		sum(EmailOrdersQTR) EmailOrdersQTR
	 from Staging.eW_Quarterly_Working
	 group by asofyear   
	 
-----------------------------------------------------------------------------------------------------------------
	 /* Update Mail Contacts for Qtr */
	print 'Update Mail Contacts for Qtr'
	 
	 Declare @MHTable varchar(50)
	 
	 select @MHTable = 'archive.MailingHistory' + convert(varchar,YEAR(@QTRStartDate))

	if object_id('Staging.eW_Quarterly_MH') is not null drop table Staging.eW_Quarterly_MH
    
    set @SQLStatement = 'select CustomerID,AdCode,NewSeg,Name,a12mf,Concatenated,FlagHoldOut,ComboID,SubjRank,PreferredCategory2,StartDate
						 into Staging.eW_Quarterly_MH from ' + @MHTable + ' (nolock)'   +
						' where Startdate >= ''' + convert(varchar,@QTRStartDate,101) + '''' +
						' and startdate < ''' + convert(varchar,@QTREndDate,101)  + ''''
	print @SQLStatement 
	
	exec sp_executesql @SQLStatement    
   

	-- If QTR is for current year, use the same update table.
	 if object_id('Staging.eW_Quarterly_MH_QTR') is not null drop table Staging.eW_Quarterly_MH_QTR  

		select a.CustomerID, 
			COUNT(b.Adcode) TotalMails
		into Staging.eW_Quarterly_MH_QTR
		from Staging.eW_Quarterly_Working a join
			Staging.eW_Quarterly_MH b on a.customerid = b.CustomerID
		group by a.customerid

		
	 update a
	 set a.MailContactsQTR = b.TotalMails
	 from Staging.eW_Quarterly_Working a join
		Staging.eW_Quarterly_MH_QTR b on a.customerid = b.customerid	
 
	----------------------------------------------------------------------------------------

	 /* Update Email Contacts for Qtr */
	print 'Update Email Contacts for Qtr'
	 
	 Declare @EmHTable varchar(50)
	 
	 select @EmHTable = 'archive.EmailHistory' + convert(varchar,YEAR(@QTRStartDate))
	 
    if object_id('Staging.eW_Quarterly_EmH') is not null drop table Staging.eW_Quarterly_EmH
    
	set @SQLStatement = 'select * into Staging.eW_Quarterly_EmH from ' + @EmHTable + ' (nolock)'   +
					' where Startdate >= ''' + convert(varchar,@QTRStartDate,101) + '''' +
					' and startdate < ''' + convert(varchar,@QTREndDate,101)  + ''''
	
	print @SQLStatement 
	exec sp_executesql @SQLStatement 
   
    if object_id('Staging.eW_Quarterly_EmH_QTR') is not null drop table Staging.eW_Quarterly_EmH_QTR    
    select a.CustomerID, 
		COUNT(b.Adcode) TotalEmails
	into Staging.eW_Quarterly_EmH_QTR
	from Staging.eW_Quarterly_Working a join
		Staging.eW_Quarterly_EmH b on a.customerid = b.CustomerID
	group by a.customerid

	 update a
	 set a.EmailContactsQTR = b.TotalEmails
	 from Staging.eW_Quarterly_Working a join
	 	Staging.eW_Quarterly_EmH_QTR b on a.customerid = b.customerid	

	/* Update FlagEngaged Flag as of beginning of the year */
	print 'Update FlagEngaged Flag as of beginning of the year'
	
	If YEAR(@QTRStartDate) > 2011
		begin
			declare @NonEngTable varchar(100)
			
			set @NonEngTable = 'Archive.Email_NonEngaged_Customers_' + @StringNextQtrDate
		
			set @SQLStatement = ' update a
			 set a.FlagEngagedCust = 0
			 from Staging.eW_Quarterly_Working a join ' +
				@NonEngTable + ' b on a.customerid = b.CustomerID'
				
			print @SQLStatement  
			exec sp_executesql @SQLStatement  			
				
		end			


	delete a
	from Marketing.eW_QTR_BaseTable a 
	where AsOfDate = @QTRStartDate
	
	insert into Marketing.eW_QTR_BaseTable
	select * from Staging.eW_Quarterly_Working
    
    --if object_id('Staging.eW_Quarterly_CCS') is not null drop table Staging.eW_Quarterly_CCS   
    --if object_id('Staging.eW_Quarterly_CDCR') is not null drop table Staging.eW_Quarterly_CDCR 
    --if object_id('Staging.eW_Quarterly_MH') is not null drop table Staging.eW_Quarterly_MH
    --if object_id('Staging.eW_Quarterly_MH_QTR') is not null drop table Staging.eW_Quarterly_MH_QTR    
    
END

GO
