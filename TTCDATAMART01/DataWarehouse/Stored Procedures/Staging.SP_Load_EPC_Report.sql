SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Staging].[SP_Load_EPC_Report]  @date date = null
as
Begin

/***********************************************/

--Use Month Start dates which have snapshots

--declare @date date = '12/1/2016'

	Declare @sql varchar(4000), @stringdate varchar(10)

	if @date is null
	begin
	set @date = cast(getdate() as date)
	End


	set @stringdate = CONVERT(varchar,  @date, 112)


	set   @sql  = '

				If object_id(''staging.EPCTemp_CampaignCustomerSignature'') is not null 
				Begin
				drop table staging.EPCTemp_CampaignCustomerSignature
				End 

				select * into staging.EPCTemp_CampaignCustomerSignature
				from DataWarehouse.Archive.CampaignCustomerSignature'+ @stringdate  + ' 

				If object_id(''staging.EPCTemp_EPCPref'') is not null 
				Begin
				drop table staging.EPCTemp_EPCPref
				END

				select * into staging.EPCTemp_EPCPref 
				from DataWarehouse.Archive.epc_preference' + @stringdate 

			exec (@sql)


				select cast(b.FMPullDate as date) AsOfDate,b.CustomerSegment, b.Frequency, b.CustomerSegmentFnl, b.NewSeg, b.Name, b.a12mf, 		
					case when b.countrycode in ('US','CA','GB','AU') then b.CountryCode							
						else 'ROW'											
						end as CountryCode,											
					isnull(a.Subscribed,0) Subscribed, a.HardBounce, a.Blacklist, a.SoftBounce,						
					case when (a.HardBounce+ a.Blacklist+ a.SoftBounce) > 0 then 'NonEmailable'					
						 when a.Subscribed = 0 then 'NonEmailable'								
						 when a.Subscribed = 1 then 'Emailable'									
						else 'Unknown'											
						end as FlagEmailable,											
					a.NewCourseAnnouncements, a.FreeLecturesClipsandInterviews, a.ExclusiveOffers, a.Frequency as EPCFrequency,				
					count(distinct b.customerid) UniqueCustCount,									
					count(a.email) as TotalEmails, case when a.email like '%@%' then 1 else 0 end as ValidEmail
				Into #EPCMonthlyLoad
					from staging.EPCTemp_CampaignCustomerSignature b left join							
					staging.EPCTemp_EPCPref a on a.CustomerID = b.CustomerID					
					group by cast(b.FMPullDate as date),b.CustomerSegment, b.Frequency, b.CustomerSegmentFnl, b.NewSeg, b.Name, b.a12mf, 		
					case when b.countrycode in ('US','CA','GB','AU') then b.CountryCode							
						else 'ROW'											
						end ,													
					isnull(a.Subscribed,0), a.HardBounce, a.Blacklist, a.SoftBounce,							
					case when (a.HardBounce+ a.Blacklist+ a.SoftBounce) > 0 then 'NonEmailable'					
						when a.Subscribed = 0 then 'NonEmailable'								
						when a.Subscribed = 1 then 'Emailable'									
						else 'Unknown'											
						end,													
					a.NewCourseAnnouncements, a.FreeLecturesClipsandInterviews, a.ExclusiveOffers, a.Frequency				
					,case when a.email like '%@%' then 1 else 0 end

			UNION

				select cast(a.Lastupdated as date) AsOfDate,'Prospects' as CustomerSegment, null Frequency, 'Prospects' as CustomerSegmentFnl, null as NewSeg, null as Name, null as a12mf, 		
					case when p.website_country in ('US','CA','GB','AU') then p.website_country							
						else 'ROW'											
						end as CountryCode,											
					isnull(a.Subscribed,0) Subscribed, a.HardBounce, a.Blacklist, a.SoftBounce,						
					case when (a.HardBounce+ a.Blacklist+ a.SoftBounce) > 0 then 'NonEmailable'					
						 when a.Subscribed = 0 then 'NonEmailable'								
						 when a.Subscribed = 1 then 'Emailable'									
						else 'Unknown'											
						end as FlagEmailable,											
					a.NewCourseAnnouncements, a.FreeLecturesClipsandInterviews, a.ExclusiveOffers, a.Frequency as EPCFrequency,				
					0 as UniqueCustCount,									
					count(a.email) as TotalEmails,
					case when a.email like '%@%' then 1 else 0 end as ValidEmail
				from staging.EPCTemp_EPCPref a
				join MagentoImports..Email_Customer_Information p on a.Email = p.subscriber_email 
				where CustomerID is null
				group by Cast(a.Lastupdated as date),case when p.website_country in ('US','CA','GB','AU') then p.website_country							
						else 'ROW'											
						end ,													
					isnull(a.Subscribed,0), a.HardBounce, a.Blacklist, a.SoftBounce,							
					case when (a.HardBounce+ a.Blacklist+ a.SoftBounce) > 0 then 'NonEmailable'					
						when a.Subscribed = 0 then 'NonEmailable'								
						when a.Subscribed = 1 then 'Emailable'									
						else 'Unknown'											
						end,													
					a.NewCourseAnnouncements, a.FreeLecturesClipsandInterviews, a.ExclusiveOffers, a.Frequency				
					,case when a.email like '%@%' then 1 else 0 end




			delete from Datawarehouse.Marketing.EPC_Report
			where AsOfDate in (select distinct AsOfDate from #EPCMonthlyLoad)



			insert into Datawarehouse.Marketing.EPC_Report 
			(AsOfDate,CustomerSegment,Frequency,CustomerSegmentFnl,NewSeg,Name,a12mf,CountryCode,
			Subscribed,HardBounce,Blacklist,SoftBounce,FlagEmailable,NewCourseAnnouncements,
			FreeLecturesClipsandInterviews,ExclusiveOffers,EPCFrequency,UniqueCustCount,TotalEmails,ValidEmail)
			
			select AsOfDate,CustomerSegment,Frequency,CustomerSegmentFnl,NewSeg,Name,a12mf,CountryCode,
					Subscribed,HardBounce,Blacklist,SoftBounce,FlagEmailable,NewCourseAnnouncements,
					FreeLecturesClipsandInterviews,ExclusiveOffers,EPCFrequency,UniqueCustCount,TotalEmails,ValidEmail
			from #EPCMonthlyLoad


If object_id('staging.EPCTemp_EPCPref') is not null 
Begin
drop table staging.EPCTemp_EPCPref
END 

If object_id('staging.EPCTemp_CampaignCustomerSignature') is not null 
Begin
drop table staging.EPCTemp_CampaignCustomerSignature
End 

End

 
GO
