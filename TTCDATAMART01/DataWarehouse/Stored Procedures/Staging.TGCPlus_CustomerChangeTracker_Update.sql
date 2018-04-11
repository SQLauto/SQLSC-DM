SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[TGCPlus_CustomerChangeTracker_Update]
	@LoadType varchar(20) = 'Update'  -- To do complete reload, parameter should be 'Reload'
AS

BEGIN
    set nocount on

		-- Get Current Status
		--drop table #current
		Select 
			A.AsOfDate,
			A.CustomerID,
			A.uuid,
			A.EmailAddress,
			A.CustStatusFlag,
			A.TGCCustFlag,
			A.PaidFlag,
			B.DSMonthCancelled_New,
			b.DS,
			b.BillingRank,
			sub.genre as PreferredCategory_LTD,
			convert(varchar(10), null) as PreferredAVCat_LTD,
			convert(varchar(10), null) as PreferredPlayerSpeed_LTD,
			convert(varchar(255), null) as PreferredPlayer_LTD
		into #current
		from  marketing.TGCPlus_CustomerSignature (nolock) A      
		left join      
		(      
		SELECT Distinct      
		CustomerID,       
		case    when Cancelled + Suspended + DeferredSuspension = 0 and RefundedAmount = 0 then NULL       
				when pre_tax_amount = 0 and MaxDS = 0 then MaxDS      
					  when LTDNetAmount = 0 then 0      
				when RefundedAmount*1./NullIf(pre_tax_amount,0) > .75 then MaxDS - DSSplits       
				else MaxDS       
				end as DSMonthCancelled_New      
		  ,DS,BillingRank,LTDAmount,LTDNetAmount ,Reactivated,LTDPaymentRank,LTDNetPaymentRank
		  FROM [DataWarehouse].[Archive].[Vw_TGCPlus_DS_Working] (nolock)       
		  where CurrentDS = 1 and DS is not null      
		) B on A.CustomerID = B.CustomerID       
		left join
		(select CustomerID, genre
		from  Archive.VW_TGCPlus_LTD_CustConsumptionBySubject
		where Rank = 1)sub on a.CustomerID = sub.CustomerID       
		
		update a
		set a.PreferredAVCat_LTD = av.FlagAudioVideo
		from #current a join
			(select CustomerID, FlagAudioVideo
			from  Archive.VW_TGCPlus_LTD_CustConsumptionByAudioVideo 
			where Rank = 1)av on a.CustomerID = av.CustomerID   
		
		update a
		set a.PreferredPlayerSpeed_LTD = ps.Playerspeed
		from #current a join
			(select CustomerID, PlayerSpeed
			from  Archive.VW_TGCPlus_LTD_CustConsumptionBySpeed 
			where Rank = 1)ps on a.CustomerID = ps.CustomerID  
			
		update a
		set a.PreferredPlayer_LTD = pl.Player
		from #current a join
		(select CustomerID, Player
		from  Archive.VW_TGCPlus_LTD_CustConsumptionByPlayer
		where Rank = 1)pl on a.CustomerID = pl.CustomerID

	truncate table DataWarehouse.Marketing.TGCPlus_CustomerPreferences

	insert into DataWarehouse.Marketing.TGCPlus_CustomerPreferences
	select distinct a.customerid, a.uuid, a.EmailAddress,
		b.PreferredAVCat_LTD,
		b.PreferredCategory_LTD,
		b.PreferredPlayer_LTD,
		b.PreferredPlayerSpeed_LTD,
		a.AsofDate
	from DataWarehouse.Marketing.TGCPlus_CustomerSignature a left join
		#current b on a.CustomerID = b.CustomerID


	-- if load type is 'Update' then run updates

	if @LoadType = 'Update'
	begin

		---- Clean up the updates from earlier today
		--delete tct
		--from Archive.TGCPlus_CustChangeTracker tct
		--where tct.AsOfDate = (select top 1 cast(cs.AsofDate as date) from Marketing.TGCPlus_CustomerSignature cs (nolock))

		-- Update the change flag to 0 for current list
		update Archive.TGCPlus_CustChangeTracker
		set FlagChange = 0


		-- add new customers:
		insert into Archive.TGCPlus_CustChangeTracker
		select a.*,1 as FlagChange	
		from #current a left join
			Archive.TGCPlus_CustChangeTracker b on a.CustomerID = b.CustomerID
		where b.CustomerID is null   
    
		-- add updates for existing Customers as needed:
   
		--drop table #changes
		select a.*, 1 as FlagChange
		into #changes
		from #current a join
			Archive.TGCPlus_CustChangeTracker b on a.CustomerID = b.CustomerID
		where (isnull(a.CustStatusFlag,'') <> isnull(b.CustStatusFlag,'')
			 or isnull(a.TGCCustFlag,'')  <> isnull(b.TGCCustFlag,'')
			 or isnull(a.PaidFlag,'')  <> isnull(b.PaidFlag,'')
			 or isnull(a.DSMonthCancelled_New,'')  <> isnull(b.DSMonthCancelled_New,'')
			 or isnull(a.DS,'') <> isnull(b.DS,'')
			 or isnull(a.BillingRank,'') <> isnull(b.BillingRank,'')
			 or isnull(a.PreferredCategory_LTD, '') <> isnull(b.PreferredCategory_LTD,''))
			 --or isnull(a.PreferredAVCat_LTD, '') <> b.PreferredAVCat_LTD,'')
			 --or isnull(a.PreferredPlayerSpeed_LTD, '') <> b.PreferredPlayerSpeed_LTD,'')
			 --or isnull(a.PreferredPlayer_LTD, '') <> b.PreferredPlayer_LTD))

		delete a
		from Archive.TGCPlus_CustChangeTracker a join
			#changes b on a.customerid = b.CustomerID

		insert into Archive.TGCPlus_CustChangeTracker 
		select *
		from #changes
	end

	else if @LoadType = 'Reload'
	begin
		truncate table Archive.TGCPlus_CustChangeTracker

		insert into Archive.TGCPlus_CustChangeTracker
		select *, 1 from #current

	end

    
END
GO
