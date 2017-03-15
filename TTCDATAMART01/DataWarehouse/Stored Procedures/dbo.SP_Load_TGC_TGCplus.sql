SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Load_TGC_TGCplus] @StartDate date = null,@EndDate Date = null
as
Begin 

/* SP to Calc TGC customer to TGCPLus customer intial Map*/

/* Set @StartDate and @EndDate, if @StartDate is historical then end date will be +1 month else +1 Day */
	
	--Declare @StartDate date,@EndDate Date


	If 	@StartDate is null 
	Begin 
	set @StartDate  = cast(Getdate()-1 as date)
	End

	If 	@EndDate is null 
	Begin
	Set @EndDate = case when Datepart(d,@StartDate) = 1 and DateAdd(m,1,@StartDate) < cast(getdate() as date)
						then DateAdd(m,1,@StartDate) 
						Else DateAdd(d,1,@StartDate) End
	End
	 --set @EndDate = '4/19/2016'
	select @StartDate,@EndDate

/* Email Matches between the @StartDate and @EndDate dates #TGCPlusEmail */    /* Note we may have Multiple emails for Same CustomerID in EPC*/

		 select 
 			a.email as EmailAddress,
			a.id TGCP_ID, 
			a.uuid TGCP_UUID, 
			a.joined as RegisteredDate,
			a.entitled_dt as IntlSubscribedDate,
			d.CustomerID,
			Rank() over(Partition by d.CustomerID order by a.id) EmailRank
		Into #TGCPlusEmail 
		from DataWarehouse.Archive.TGCPlus_User a
		left join Marketing.epc_preference d 
		on a.email = d.Email
		Left join Datawarehouse.Mapping.TGC_TGCplus Map
		on map.TGCP_ID = a.id and Map.Customerid = d.CustomerID
		where cast(a.entitled_dt as date) between @StartDate and  @EndDate
		and a.email not like '%+%'
		and a.email not like '%plustest%'
		and a.email not like '%teachco%'
		and Map.TGCP_ID is null
		and d.CustomerID is not null

		Union 

		select 
 			a.email as EmailAddress,
			a.id TGCP_ID, 
			a.uuid TGCP_UUID, 
			a.joined as RegisteredDate,
			a.entitled_dt as IntlSubscribedDate,
			d.CustomerID,
			Rank() over(Partition by d.CustomerID order by a.id) EmailRank
		from DataWarehouse.Archive.TGCPlus_User a
		left join Marketing.epc_preference d 
		on a.email = d.Email
		Left join Datawarehouse.Mapping.TGC_TGCplus Map
		on map.TGCP_ID = a.id and Map.Customerid = d.CustomerID
		where cast(a.entitled_dt as date) < @EndDate
		and a.email not like '%+%'
		and a.email not like '%plustest%'
		and a.email not like '%teachco%' 
		and Map.TGCP_ID is null  
		and d.CustomerID is not null
 


/* TGCPlus Address match after Merge_Dupes (SP_Load_TGCplus_Merge_Dupes) */

		Select MD.*
    	Into #Merge_Dupes 
		from Datawarehouse.mapping.TGCplus_Merge_Dupes MD
		join (select TGCPlusCustomerid,min(Merge_Date) Min_Merge_Date
				from Datawarehouse.mapping.TGCplus_Merge_Dupes
				group by TGCplusCustomerid
			 )MD_min
		on MD.TGCPlusCustomerid = MD_min.TGCPlusCustomerid
		and MD_min.Min_Merge_Date = MD.Merge_Date
		where MD.Rank = 1


 	    select 
			a.id TGCP_ID, 
			a.uuid TGCP_UUID, 
			a.joined as RegisteredDate,
			a.entitled_dt as IntlSubscribedDate,
			MD.Acctno,
			MD.KeptPin
		 Into #TGCPlusAddress 
		 from DataWarehouse.Archive.TGCPlus_User a
				join #Merge_Dupes MD
				on MD.TGCPlusCustomerid = a.id
		where cast(a.entitled_dt as date) between @StartDate and  @EndDate
		and a.email not like '%+%'
		and a.email not like '%plustest%'
		and a.email not like '%teachco%'
		and MD.acctno is not null

		Union 
		/* Add Previously unmatched */
		select 
 			a.id TGCP_ID, 
			a.uuid TGCP_UUID, 
			a.joined as RegisteredDate,
			a.entitled_dt as IntlSubscribedDate,
			MD.Acctno,
			MD.KeptPin
		from DataWarehouse.Archive.TGCPlus_User a
		join #Merge_Dupes MD
		on MD.TGCPlusCustomerid = a.id
		Left join Datawarehouse.Mapping.TGC_TGCplus Map
		on map.TGCP_ID = a.id
		where cast(a.entitled_dt as date) < @EndDate 
		and a.email not like '%+%'
		and a.email not like '%plustest%'
		and a.email not like '%teachco%' 
		and Map.TGCP_ID is null
		and MD.acctno is not null

		select E.*,cast(min(Coalesce(RFM.AsOfDate, CCS.FMpulldate)) as date)as AsOfDate 
		Into #TGCPlusEmailAsOfDate
		from #TGCPlusEmail E
		left join DataWarehouse.Marketing.TGC_Monthly_RFM RFM
		on RFM.CustomerID = E.CustomerID
		and Dateadd(Month,1,RFM.AsOfDate) >= E.IntlSubscribedDate
		left join DataWarehouse.Marketing.CampaignCustomerSignature CCS
		on CCS.CustomerID = E.CustomerID
		group by  E.EmailAddress,	TGCP_ID,	TGCP_UUID,	RegisteredDate,	IntlSubscribedDate,	E.CustomerID,EmailRank


		select Ad.*, Cast(min(Coalesce(RFM.AsOfDate, CCS.FMpulldate)) as date) as AsOfDate 
		into #TGCPlusAddressAsOfDate
		from #TGCPlusAddress Ad
		left join DataWarehouse.Marketing.TGC_Monthly_RFM RFM
		on RFM.CustomerID = Ad.acctno
		and Dateadd(Month,1,RFM.AsOfDate) >= Ad.IntlSubscribedDate
		left join DataWarehouse.Marketing.CampaignCustomerSignature CCS
		on CCS.CustomerID = Ad.acctno
		group by  TGCP_ID	,TGCP_UUID	,RegisteredDate	,IntlSubscribedDate,Acctno	,KeptPin



-- table #TGC_Customer

		select * ,cast(null as Bigint) TGCP_ID
		into #TGC_Customer 
		from DataWarehouse.Marketing.TGC_Monthly_RFM
		where 1=0



/*#TGC_Customer*/	


		Insert Into #TGC_Customer

		select RFM.* ,E.TGCP_ID
		from DataWarehouse.Marketing.TGC_Monthly_RFM RFM
		inner join (	select Distinct Customerid,TGCP_ID ,AsOfDate 
							from #TGCPlusEmailAsOfDate
					Union 
						select Distinct Acctno,TGCP_ID ,AsOfDate 
							from #TGCPlusAddressAsOfDate
					) E
		on RFM.CustomerID = E.CustomerID and RFM.AsOfDate = E.AsOfDate
		left join #TGC_Customer C
		on C.CustomerID = E.CustomerID and C.TGCP_ID = E.TGCP_ID
		where C.CustomerID is null or C.TGCP_ID is null




		Insert Into #TGC_Customer
		select 	ccs.CustomerID,	ccs.CustomerSince,cast(	ccs.FMPullDate as date) as AsOfDate,	ccs.NewSeg,	ccs.Name,	ccs.a12mf,	ccs.ComboID,
							ccs.CustomerSegment,	ccs.Frequency,	ccs.CustomerSegmentNew,	ccs.CustomerSegmentFnl,
							ccs.customerSegment +  case when CCS.frequency = 'F2' then '_Multi' 
														when CCS.frequency = 'F1' then '_Single' 
														else '' end as CustomerSegmentFrcst,
							ccs.FirstName,	ccs.LastName,	ccs.Address1,	ccs.Address2,	ccs.Address3,	ccs.City,	ccs.State,	ccs.postalCode,	ccs.CountryCode 
							,E.TGCP_ID
		from DataWarehouse.Marketing.CampaignCustomerSignature CCS
		inner join (	select Distinct Customerid,TGCP_ID ,AsOfDate 
							from #TGCPlusEmailAsOfDate
					Union 
						select Distinct Acctno,TGCP_ID ,AsOfDate 
							from #TGCPlusAddressAsOfDate
					)  E
		on ccs.CustomerID = E.CustomerID and cast(ccs.FMPullDate as date) = E.AsOfDate
		left join #TGC_Customer C
		on C.CustomerID = E.CustomerID and C.TGCP_ID=E.TGCP_ID
		where C.CustomerID is null or C.TGCP_ID is null


-- table #EmailMatch

		select  c.*,E.EmailAddress as TGCPlusEmail,TGCP_UUID,RegisteredDate,IntlSubscribedDate,
				case when c.customersince < E.RegisteredDate then CONVERT(varchar(15),'TGC')
					Else CONVERT(varchar(15),'TGCPlus')
					end FirstCustBUReg,
				case when c.customersince < E.IntlSubscribedDate then CONVERT(varchar(15),'TGC')
					Else CONVERT(varchar(15),'TGCPlus')
					end FirstCustBUSub,
				DATEDIFF(day, c.customersince, E.RegisteredDate) as TenureDaysReg,	
				DATEDIFF(day, c.customersince, E.IntlSubscribedDate) as TenureDaysSub, 
				case when DM.Customerid is not null then 1 else 0 End as TGCPurchaseFlag,
				Rank() over(Partition by c.CustomerID,C.TGCP_ID	order by IntlSubscribedDate, DM.Dateordered desc, DM.OrderId desc) RNK,
				DM.NetOrderAmount
		into #EmailMatch
		from #TGC_Customer C
		join #TGCPlusEmailAsOfDate E
		on E.CustomerID=C.Customerid and E.TGCP_ID = C.TGCP_ID
		left join DataWarehouse.Marketing.DMPurchaseOrders DM
		on DM.CustomerID = E.CustomerID
		and DM.DateOrdered between E.IntlSubscribedDate and E.AsOfDate
	 


		 select * 
		  Into #EmailMatchFinal 
		 from #EmailMatch
		 where RNK = 1 
		 
		 
		 Update #EmailMatchFinal
		 set NewSeg = case when NetOrderAmount<=220 then 1 else 2 end,
			 Name =  case when NetOrderAmount<=220 then '6sL' else '6s3' end,
			 a12mf = 0,
			 ComboID = case when NetOrderAmount<=220 then '16sL0' else '26s30' end,
			 CustomerSegment = 'Active',
			 Frequency ='F1',
			 CustomerSegmentNew = 'NewToFile',
			 CustomerSegmentFnl = 'NewToFile_Single',
			 CustomerSegmentFrcst = 'Active_Single'   
		--select * from #EmailMatchFinal
		 where FirstCustBUSub = 'TGCPlus' and TGCPurchaseFlag = 1


 		select  c.*,keptpin as keptpin,TGCP_UUID,RegisteredDate,IntlSubscribedDate,
				case when c.customersince < Ad.RegisteredDate then CONVERT(varchar(15),'TGC')
					Else CONVERT(varchar(15),'TGCPlus')
					end FirstCustBUReg,
				case when c.customersince < Ad.IntlSubscribedDate then CONVERT(varchar(15),'TGC')
					Else CONVERT(varchar(15),'TGCPlus')
					end FirstCustBUSub,
				DATEDIFF(day, c.customersince, Ad.RegisteredDate) as TenureDaysReg,	
				DATEDIFF(day, c.customersince, Ad.IntlSubscribedDate) as TenureDaysSub, 
				case when DM.Customerid is not null then 1 else 0 End as TGCPurchaseFlag,
				Rank() over(Partition by c.CustomerID,C.TGCP_ID	order by IntlSubscribedDate, DM.Dateordered desc, DM.OrderId desc) RNK,
				DM.NetOrderAmount
		into #AddressMatch
		from #TGC_Customer C
		join #TGCPlusAddressAsOfDate Ad
		on Ad.acctno=C.Customerid and Ad.TGCP_ID = C.TGCP_ID
		left join DataWarehouse.Marketing.DMPurchaseOrders DM
		on DM.CustomerID = Ad.acctno
		and DM.DateOrdered between Ad.IntlSubscribedDate and Ad.AsOfDate

		select * 
		Into #AddressMatchFinal 
		from #AddressMatch
		where RNK = 1 

		 Update #AddressMatchFinal
		 set NewSeg = case when NetOrderAmount<=220 then 1 else 2 end,
			 Name =  case when NetOrderAmount<=220 then '6sL' else '6s3' end,
			 a12mf = 0,
			 ComboID = case when NetOrderAmount<=220 then '16sL0' else '26s30' end,
			 CustomerSegment = 'Active',
			 Frequency ='F1',
			 CustomerSegmentNew = 'NewToFile',
			 CustomerSegmentFnl = 'NewToFile_Single',
			 CustomerSegmentFrcst = 'Active_Single'   
		--select * from  #AddressMatchFinal
		 where FirstCustBUSub = 'TGCPlus' and TGCPurchaseFlag = 1


	Insert into Datawarehouse.Mapping.TGC_TGCplus
	(CustomerID,CustomerSince,AsOfDate,NewSeg,Name,a12mf,ComboID,CustomerSegment,Frequency,CustomerSegmentNew,CustomerSegmentFnl,CustomerSegmentFrcst,
	FirstName,LastName,Address1,Address2,Address3,City,State,postalCode,CountryCode,TGCP_ID)

	select 	c.CustomerID,CustomerSince,AsOfDate,NewSeg,Name,a12mf,ComboID,CustomerSegment,Frequency,CustomerSegmentNew,CustomerSegmentFnl,CustomerSegmentFrcst,
	FirstName,LastName,Address1,Address2,Address3,City,State,postalCode,CountryCode,C.TGCP_ID
	from #TGC_Customer c
	left join (select Customerid,TGCP_ID from Datawarehouse.Mapping.TGC_TGCplus) Map
	on C.CustomerID = Map.Customerid  and C.TGCP_ID = Map.TGCP_ID
	where Map.Customerid is null  and  Map.TGCP_ID is null

	 

		Update Map
		set  
		    Map.AsOfDate = case when Map.TGCPEmailMatchFlag = 0 then E.AsOfDate else Map.AsOfDate End,
			Map.NewSeg= case when Map.TGCPAddressMatchFlag = 0 then E.NewSeg else Map.NewSeg End,	
			Map.Name= case when Map.TGCPAddressMatchFlag = 0 then E.Name else Map.Name End,
			Map.a12mf= case when Map.TGCPAddressMatchFlag = 0 then E.a12mf else Map.a12mf End,	
			Map.ComboID=case when Map.TGCPAddressMatchFlag = 0 then E.ComboID else Map.ComboID End,
			Map.CustomerSegment	=case when Map.TGCPAddressMatchFlag = 0 then E.CustomerSegment else Map.CustomerSegment End,
			Map.Frequency =	case when Map.TGCPEmailMatchFlag = 0 then E.Frequency else Map.Frequency End,
			Map.CustomerSegmentNew =case when Map.TGCPAddressMatchFlag = 0 then  E.CustomerSegmentNew else Map.CustomerSegmentNew End,
			Map.CustomerSegmentFnl =case when Map.TGCPAddressMatchFlag = 0 then  E.CustomerSegmentFnl else Map.CustomerSegmentFnl End,
			Map.CustomerSegmentFrcst =case when Map.TGCPAddressMatchFlag = 0 then  E.CustomerSegmentFrcst else Map.CustomerSegmentFrcst End,
			Map.TGCP_ID= E.TGCP_ID,	
			Map.TGCP_UUID=E.TGCP_UUID,	
			Map.RegisteredDate=E.RegisteredDate,	
			Map.IntlSubscribedDate=E.IntlSubscribedDate,	
			Map.TGCP_EmailAddress=E.TGCPlusEmail,	
			Map.MatchType= case when Isnull(Map.MatchType,'Email') = 'Email' then 'Email' 
						 Else 'Both' End,	
			Map.FirstCustBUReg=E.FirstCustBUReg,	
			Map.FirstCustBUSub=E.FirstCustBUSub,
			Map.TenureDaysReg=E.TenureDaysReg,	 
			Map.TenureDaysSub=E.TenureDaysSub,
			map.TGCPEmailMatchFlag =1,
			Map.TGCPurchaseFlag = E.TGCPurchaseFlag,
			Map.LastUpdatedDate = getdate()
		--select E.* 
		from Datawarehouse.Mapping.TGC_TGCplus Map
		join #EmailMatchFinal E
		on E.CustomerID = Map.CustomerID and E.TGCP_ID = Map.TGCP_ID
		where isnull(Map.TGCPEmailMatchFlag,0) = 0
 


		 Update Map
		set  
		    Map.AsOfDate = case when Map.TGCPEmailMatchFlag = 0 then A.AsOfDate else Map.AsOfDate End,
			Map.NewSeg= case when Map.TGCPEmailMatchFlag = 0 then A.NewSeg else Map.NewSeg End,	
			Map.Name= case when Map.TGCPEmailMatchFlag = 0 then A.Name else Map.Name End,
			Map.a12mf= case when Map.TGCPEmailMatchFlag = 0 then A.a12mf else Map.a12mf End,	
			Map.ComboID=case when Map.TGCPEmailMatchFlag = 0 then A.ComboID else Map.ComboID End,
			Map.CustomerSegment	=case when Map.TGCPEmailMatchFlag = 0 then A.CustomerSegment else Map.CustomerSegment End,
			Map.Frequency =	case when Map.TGCPEmailMatchFlag = 0 then A.Frequency else Map.Frequency End,
			Map.CustomerSegmentNew =case when Map.TGCPEmailMatchFlag = 0 then  A.CustomerSegmentNew else Map.CustomerSegmentNew End,
			Map.CustomerSegmentFnl =case when Map.TGCPEmailMatchFlag = 0 then  A.CustomerSegmentFnl else Map.CustomerSegmentFnl End,
			Map.CustomerSegmentFrcst =case when Map.TGCPEmailMatchFlag = 0 then  A.CustomerSegmentFrcst else Map.CustomerSegmentFrcst End,
			Map.TGCP_ID= A.TGCP_ID,	
			Map.TGCP_UUID=A.TGCP_UUID,	
			Map.RegisteredDate=A.RegisteredDate,	
			Map.IntlSubscribedDate=A.IntlSubscribedDate,	
			Map.KeptPin=A.KeptPin,	
			Map.MatchType= case when Isnull(Map.MatchType,'Address') = 'Address' then 'Address' 
						 Else 'Both' End,	
			Map.FirstCustBUReg=A.FirstCustBUReg,	
			Map.FirstCustBUSub=A.FirstCustBUSub,
			Map.TenureDaysReg=A.TenureDaysReg,	 
			Map.TenureDaysSub=A.TenureDaysSub,
			map.TGCPAddressMatchFlag =1,
			Map.TGCPurchaseFlag = A.TGCPurchaseFlag,
			Map.LastUpdatedDate = getdate()
		--select A.* 
		from Datawarehouse.Mapping.TGC_TGCplus Map
		join #AddressMatch A
		on A.CustomerID = Map.CustomerID and A.TGCP_ID = Map.TGCP_ID
		where Map.TGCPAddressMatchFlag = 0
		 

		Drop table #AddressMatch
		Drop table #AddressMatchFinal
		Drop table #EmailMatch
		Drop table #EmailMatchFinal
		Drop table #Merge_Dupes
		Drop table #TGC_Customer
		Drop table #TGCPlusAddress
		Drop table #TGCPlusAddressAsOfDate
		Drop table #TGCPlusEmail
		Drop table #TGCPlusEmailAsOfDate


		select Count(*) Cnt 
		from Datawarehouse.Mapping.TGC_TGCplus 
		where cast(LastUpdatedDate as date) = cast(getdate() as date)
 
		

End
GO
