SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_Load_Omni_TGC_PRSPCT_CourseConsmption]
as
Begin

	select MagentoUserID, min(ActionDate) MinActionDate
	into #MagentoUserID
	from DataWarehouse.Archive.Omni_TGC_Streaming
	group by MagentoUserID
 

	CREATE TABLE #MagentoUserIDProspecting (
		[MagentoUserID] [varchar](255) NULL,
		[MinActionDate] [date] NULL,
		[customerid] [nvarchar](20) NULL,
		[CustomerSince] [datetime] NULL
	) 

	Declare @DateMagentoUserID Date
	set @DateMagentoUserID = '1/1/2017'

	While @DateMagentoUserID < cast(getdate() as date)
	Begin 

	--Print 'Inserting for '  + Cast(@DateMagentoUserID as varchar(10))

	Insert Into #MagentoUserIDProspecting

	select distinct a.*, C.CustomerID,c.CustomerSince 
	from #MagentoUserID a
	left join DataWarehouse.mapping.Customerid_Userid_MarketingCloudID  b
	on a.MagentoUserID = b.web_user_id
	left join DataWarehouse.marketing.CampaignCustomerSignature c
	on c.CustomerID = b.CustomerID --and a.MinActionDate < cast(c.CustomerSince  as date)
	left join #MagentoUserIDProspecting P
	on p.MagentoUserID = a.MagentoUserID 
	Where p.MagentoUserID is null
	and (a.MinActionDate < cast(c.CustomerSince  as date) or c.CustomerSince is null)
	and a.MinActionDate =  @DateMagentoUserID 
 
	set @DateMagentoUserID  = Dateadd(d,1,@DateMagentoUserID)

	End


	/**Duplicate Deletes**/
	delete from #MagentoUserIDProspecting
	where MagentoUserID in (
	select  MagentoUserID from #MagentoUserIDProspecting
	group by MagentoUserID
	having count(*)>1)

	update p
	set p.CustomerSince =  MinDateOrdered   
	from #MagentoUserIDProspecting p
	join (select CustomerID, min(DateOrdered)MinDateOrdered from DataWarehouse.Marketing.CompleteCoursePurchase group by CustomerID)ccp
	on ccp.CustomerID = p.CustomerID 
	where MinDateOrdered < p.CustomerSince

	select p.MagentoUserID as IntlMagentoUserID,p.MinActionDate,	p.CustomerSince,	p.customerid as Intlcustomerid
	,S.*
	into #Prspct
	 from #MagentoUserIDProspecting P
	left join [Archive].[Omni_TGC_Streaming] S
	on p.MagentoUserID = S.MagentoUserID
	and S.Actiondate < isnull(Cast(p.CustomerSince as date),getdate())

	select 
	IntlMagentoUserID,MinActionDate,CustomerSince,Intlcustomerid,ActionDate,MobileDeviceType,MobileDevice,Platform,
	case when CourseID between 1 and 10000 then CourseID
		 when MediaName like 'PFL%' then Substring(MediaName,4,4)
		 when MediaName like 'Promo_%' and Isnumeric(replace(Substring(MediaName,6,5),'_','')) = 1 then replace(Substring(MediaName,6,5),'_','')
 		 when MediaName like 'ZVFREE%' and Isnumeric(left(replace((Right(MediaName,8)),'-',''),4)) = 1 then left(replace((Right(MediaName,8)),'-',''),4)
		 else 0
		 end CourseID
	 ,Count(distinct MediaName)TotalLectures,	Sum(TotalActions)TotalActions,Sum(MediaTimePlayed)MediaTimePlayed
	 ,cast(0 as int) as PurchasedFlag
	 ,Cast(null as date) DateOrdered
	  Into #PrspctFinal
	from #Prspct
	where IntlMagentoUserID not in ('No-Id-Available')
	group by IntlMagentoUserID,MinActionDate,CustomerSince,Intlcustomerid,ActionDate,MobileDeviceType,MobileDevice,Platform,
	case when CourseID between 1 and 10000 then CourseID
		 when MediaName like 'PFL%' then Substring(MediaName,4,4)
		 when MediaName like 'Promo_%' and Isnumeric(replace(Substring(MediaName,6,5),'_','')) = 1 then replace(Substring(MediaName,6,5),'_','')
 		 when MediaName like 'ZVFREE%' and Isnumeric(left(replace((Right(MediaName,8)),'-',''),4)) = 1 then left(replace((Right(MediaName,8)),'-',''),4)
		 else 0
		 end

	update p
	set p.PurchasedFlag = 1
	,p.DateOrdered = ccp.DateOrdered
	from #PrspctFinal p
	join DataWarehouse.mapping.Customerid_Userid_MarketingCloudID  b
	on p.IntlMagentoUserID = b.web_user_id
	join DataWarehouse.Marketing.CompleteCoursePurchase ccp
	on ccp.CustomerID = b.CustomerID 
	where ccp.CourseID = p.CourseID
	and p.Intlcustomerid is not null


	select MarketingCloudVisitorID, min(ActionDate) MinActionDate
	into #MarketingCloudVisitorID
	from DataWarehouse.Archive.Omni_TGC_Streaming
	group by MarketingCloudVisitorID

 
 	CREATE TABLE #MarketingCloudVisitorIDProspecting (
		[MarketingCloudVisitorID] [varchar](255) NULL,
		[MinActionDate] [date] NULL,
		[customerid] [nvarchar](20) NULL,
		[CustomerSince] [datetime] NULL
	) 


	Declare @DateMarketingCloudVisitorID Date
	set @DateMarketingCloudVisitorID = '1/1/2017'

	While @DateMarketingCloudVisitorID < cast(getdate() as date)
	Begin 

	--Print 'Inserting for '  + Cast(@DateMarketingCloudVisitorID as varchar(10))

	Insert Into #MarketingCloudVisitorIDProspecting

	select distinct a.*, C.CustomerID,c.CustomerSince 
	from #MarketingCloudVisitorID a
	left join DataWarehouse.mapping.Customerid_Userid_MarketingCloudID  b
	on a.MarketingCloudVisitorID = b.MarketingCloudVisitorID
	left join DataWarehouse.marketing.CampaignCustomerSignature c
	on c.CustomerID = b.CustomerID --and a.MinActionDate < cast(c.CustomerSince  as date)
	left join #MarketingCloudVisitorIDProspecting P
	on p.MarketingCloudVisitorID = a.MarketingCloudVisitorID
	Where p.MarketingCloudVisitorID is null
	and (a.MinActionDate < cast(c.CustomerSince  as date) or c.CustomerSince is null)
	and a.MinActionDate =  @DateMarketingCloudVisitorID 
 
	set @DateMarketingCloudVisitorID  = Dateadd(d,1,@DateMarketingCloudVisitorID)

	End


	/**Duplicate Deletes**/

	select 1;

	With Dupes as   
	(  
	Select MarketingCloudVisitorID,customerid,	CustomerSince, row_number() over (partition by MarketingCloudVisitorID order by isnull(CustomerSince,getdate())) as rnk  
	from #MarketingCloudVisitorIDProspecting
	)  
	delete  from Dupes where rnk >1  ; 

	update p
	set p.CustomerSince = MinDateOrdered  
	from #MarketingCloudVisitorIDProspecting p
	join (select CustomerID, min(DateOrdered)MinDateOrdered from DataWarehouse.Marketing.CompleteCoursePurchase group by CustomerID)ccp
	on ccp.CustomerID = p.CustomerID 
	where MinDateOrdered < p.CustomerSince

	select p.MarketingCloudVisitorID as IntlMarketingCloudVisitorID,p.MinActionDate,	p.CustomerSince,	p.customerid as Intlcustomerid
	,S.*
	into #Prspct2
	 from #MarketingCloudVisitorIDProspecting P
	left join [Archive].[Omni_TGC_Streaming] S
	on p.MarketingCloudVisitorID = S.MarketingCloudVisitorID
	and S.Actiondate < isnull(Cast(p.CustomerSince as date),getdate())

	select 
	IntlMarketingCloudVisitorID,MinActionDate,CustomerSince,Intlcustomerid,ActionDate,MobileDeviceType,MobileDevice,Platform,
	case when CourseID between 1 and 10000 then CourseID
		 when MediaName like 'PFL%' then Substring(MediaName,4,4)
		 when MediaName like 'Promo_%' and Isnumeric(replace(Substring(MediaName,6,5),'_','')) = 1 then replace(Substring(MediaName,6,5),'_','')
 		 when MediaName like 'ZVFREE%' and Isnumeric(left(replace((Right(MediaName,8)),'-',''),4)) = 1 then left(replace((Right(MediaName,8)),'-',''),4)
		 else 0
		 end CourseID
	 ,Count(distinct MediaName)TotalLectures,	Sum(TotalActions)TotalActions,Sum(MediaTimePlayed)MediaTimePlayed
	 ,cast(0 as int) as PurchasedFlag
	 ,Cast(null as date) DateOrdered
	  Into #PrspctFinal2
	from #Prspct2
	group by IntlMarketingCloudVisitorID,MinActionDate,CustomerSince,Intlcustomerid,ActionDate,MobileDeviceType,MobileDevice,Platform,
	case when CourseID between 1 and 10000 then CourseID
		 when MediaName like 'PFL%' then Substring(MediaName,4,4)
		 when MediaName like 'Promo_%' and Isnumeric(replace(Substring(MediaName,6,5),'_','')) = 1 then replace(Substring(MediaName,6,5),'_','')
 		 when MediaName like 'ZVFREE%' and Isnumeric(left(replace((Right(MediaName,8)),'-',''),4)) = 1 then left(replace((Right(MediaName,8)),'-',''),4)
		 else 0
		 end

	update p
	set p.PurchasedFlag = 1
	,p.DateOrdered = ccp.DateOrdered
	from #PrspctFinal2 p
	join DataWarehouse.mapping.Customerid_Userid_MarketingCloudID  b
	on p.IntlMarketingCloudVisitorID = b.MarketingCloudVisitorID
	join DataWarehouse.Marketing.CompleteCoursePurchase ccp
	on ccp.CustomerID = b.CustomerID 
	where ccp.CourseID = p.CourseID
	and p.Intlcustomerid is not null

 
	select 'IntlMagentoUserID'  ProspectType,IntlMagentoUserID as ProspectID ,MinActionDate,Intlcustomerid as Customerid,CustomerSince,ActionDate,MobileDeviceType,
	MobileDevice,Platform,CourseID,TotalLectures,TotalActions,MediaTimePlayed,PurchasedFlag,DateOrdered
	into #Final
	from #PrspctFinal
	union all
	select 'IntlMarketingCloudVisitorID' ProspectType,IntlMarketingCloudVisitorID as ProspectID ,MinActionDate,Intlcustomerid as Customerid,CustomerSince,ActionDate,MobileDeviceType,MobileDevice,
	Platform,CourseID,TotalLectures,TotalActions,MediaTimePlayed,PurchasedFlag,DateOrdered
	from #PrspctFinal2
 
	select Courseid, 
	Count(Distinct ProspectID)DistinctProspectIDCounts,
	Count(Distinct Customerid)DistinctCustomerid,
	Sum(TotalLectures)TotalLectures,
	Sum(TotalActions)TotalActions,
	Sum(MediaTimePlayed)TotalMediaTimePlayed,
	Sum(Case when PurchasedFlag =  1 then MediaTimePlayed else 0 end)PurchasedTotalMediaTimePlayed,
	Count(distinct Case when PurchasedFlag =  1 then Customerid else null end)Purchases
	into #Course
	from #Final
	where ActionDate is not NULL
	group by Courseid 
 

  If object_id ('Archive.Omni_TGC_PRSPCT_CourseConsmption') is not null  
 drop table Archive.Omni_TGC_PRSPCT_CourseConsmption  


	select 	PRS.Courseid,C.CourseName,C.AbbrvCourseName,C.ReleaseDate,PrimaryWebCategory,PrimaryWebSubcategory,TGCPlusSubjectCategory,
	DistinctProspectIDCounts,DistinctCustomerid,TotalLectures,TotalActions,TotalMediaTimePlayed,PurchasedTotalMediaTimePlayed,Purchases,getdate() as DMLastUpdated 
	into Archive.Omni_TGC_PRSPCT_CourseConsmption
	from #Course Prs
	join DataWarehouse.Staging.Vw_DMCourse c
	on c.CourseID = Prs.CourseID
	where c.FlagActive = 1
 
 

End

GO
