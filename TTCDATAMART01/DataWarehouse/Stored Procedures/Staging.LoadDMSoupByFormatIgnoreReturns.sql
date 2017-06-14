SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadDMSoupByFormatIgnoreReturns]
AS
BEGIN
	set nocount on
    
	 if object_id('staging.TempDMSOUPByFormatIgnoreReturns') is not null 
			truncate table staging.TempDMSOUPByFormatIgnoreReturns
        
	insert into staging.TempDMSOUPByFormatIgnoreReturns
	select *,
		case when CDUnits > 0 then 1 else 0 end as FlagCD,
		case when DVDUnits > 0 then 1 else 0 end as FlagDVD,
		case when AudioTapeUnits > 0 then 1 else 0 end as FlagAudioTape,
		case when VHSUnits > 0 then 1 else 0 end as FlagVHS,
		case when AudioDLUnits > 0 then 1 else 0 end as FlagAudioDL,
		case when VideoDLUnits > 0 then 1 else 0 end as FlagVideoDL,
		case when TranscriptUnits > 0 then 1 else 0 end as FlagTranscript,
		case when DigitalTranscriptUnits > 0 then 1 else 0 end as FlagDigitalTranscript,
		case when PhysicalUnits > 0 then 1 else 0 end as FlagPhysical,
		case when DigitalUnits > 0 then 1 else 0 end as FlagDigital,
		case when OrderSource = 'W' then 'Web'
			when OrderSource = 'P' then 'Phone'
			when OrderSource = 'M' then 'Mail'
			when OrderSource = 'E' then 'Email'
			else 'Other'
		end as OrderSourceRU,
		null as MD_ChannelID,
		null as MD_Channel,
		null as MD_ChannelRU,
		0 as Adj_CDSales,
		0 as Adj_DVDSales,
		0 as Adj_AudioTapeSales,
		0 as Adj_VHSSales,
		0 as Adj_AudioDLSales,
		0 as Adj_VideoDLSales,
		0 as Adj_TranscriptSales,
		0 as Adj_DigitalTranscriptSales,
		0 as Adj_DigitalSales,
		0 as Adj_PhysicalSales,
		0 as Adj_TotalMerchandizeSales
	from Staging.vwDMSOUPByFormatIgnoreReturns 
	
	-- Update MD Channel information
	update a
	set a.MD_ChannelID = b.ChannelID,
		a.MD_Channel = b.MD_Channel,
		a.MD_ChannelRU = case when b.ChannelID in (11,12,13,14,47,54,55,56,57,58) then 'Digital Marketing'
							when b.ChannelID in (6,7,44) then 'Email'
							when b.ChannelID in (1,2,3,8,9) then 'Physical Mailing'
							when b.ChannelID in (4) then 'SpaceAds'
							when b.ChannelID in (15,16,17) then 'Web Default'
							else 'Other'
						end
	--select a.MD_
	from Staging.TempDMSOUPByFormatIgnoreReturns a join
		Mapping.vwAdcodesAll b on a.AdCode = b.AdCode	

	-- update adjusted sales numbers
	-- distribute shipping $ to all physical formats and discounts to all digital and physical formats

	update staging.TempDMSOUPByFormatIgnoreReturns
	set Adj_AudioDLSales = case when TotalMerchandizeSales = 0 then 0 -- null
							   else Isnull(AudioDLSales,0) + ((Isnull(AudioDLSales,0)/(TotalMerchandizeSales))*isnull(DiscountAmount,0))
							end 


	update staging.TempDMSOUPByFormatIgnoreReturns
	set Adj_VideoDLSales = case when TotalMerchandizeSales = 0 then 0 -- null
							   else Isnull(VideoDLSales,0) + ((Isnull(VideoDLSales,0)/(TotalMerchandizeSales))*isnull(DiscountAmount,0))
							end 


	update staging.TempDMSOUPByFormatIgnoreReturns
	set Adj_DigitalTranscriptSales = case when TotalMerchandizeSales = 0 then 0 -- null
							   else Isnull(DigitalTranscriptSales,0) + ((Isnull(DigitalTranscriptSales,0)/(TotalMerchandizeSales))*isnull(DiscountAmount,0))
							end 

	update staging.TempDMSOUPByFormatIgnoreReturns
	set Adj_DVDSales = case when PhysicalSales = 0 then 0 -- null
							when TotalMerchandizeSales = 0 then 0
							else Isnull(DVDSales,0) + ((Isnull(DVDSales,0)/(TotalMerchandizeSales))*isnull(DiscountAmount,0)) + ((Isnull(DVDSales,0)/(PhysicalSales))*isnull(ShippingCharge,0))
						end 

	update staging.TempDMSOUPByFormatIgnoreReturns
	set Adj_CDSales = case when PhysicalSales = 0 then 0 -- null
							when TotalMerchandizeSales = 0 then 0
						 		else Isnull(CDSales,0) + ((Isnull(CDSales,0)/(TotalMerchandizeSales))*isnull(DiscountAmount,0)) + ((Isnull(CDSales,0)/(PhysicalSales))*isnull(ShippingCharge,0))
							end 

	update staging.TempDMSOUPByFormatIgnoreReturns
	set Adj_TranscriptSales = case when PhysicalSales = 0 then 0 -- null
							when TotalMerchandizeSales = 0 then 0
							   else Isnull(TranscriptSales,0) + ((Isnull(TranscriptSales,0)/(TotalMerchandizeSales))*isnull(DiscountAmount,0)) + ((Isnull(TranscriptSales,0)/(PhysicalSales))*isnull(ShippingCharge,0))
							end 


	update staging.TempDMSOUPByFormatIgnoreReturns
	set Adj_VHSSales = case when PhysicalSales = 0 then 0 -- null
							when TotalMerchandizeSales = 0 then 0
							  else Isnull(VHSSales,0) + ((Isnull(VHSSales,0)/(TotalMerchandizeSales))*isnull(DiscountAmount,0)) + ((Isnull(VHSSales,0)/(PhysicalSales))*isnull(ShippingCharge,0))
						end 


	update staging.TempDMSOUPByFormatIgnoreReturns
	set Adj_AudioTapeSales = case when PhysicalSales = 0 then 0 -- null
							when TotalMerchandizeSales = 0 then 0
							 else Isnull(AudioTapeSales,0) + ((Isnull(AudioTapeSales,0)/(TotalMerchandizeSales))*isnull(DiscountAmount,0)) + ((Isnull(AudioTapeSales,0)/(PhysicalSales))*isnull(ShippingCharge,0))
						  end 


	update  staging.TempDMSOUPByFormatIgnoreReturns
	set Adj_DigitalSales = Adj_AudioDLSales + Adj_VideoDLSales + Adj_DigitalTranscriptSales,
		Adj_PhysicalSales = Adj_CDSales + Adj_DVDSales + Adj_TranscriptSales + Adj_VHSSales + Adj_AudioTapeSales,
		Adj_TotalMerchandizeSales = Adj_AudioDLSales + Adj_VideoDLSales + Adj_DigitalTranscriptSales + Adj_CDSales + Adj_DVDSales + Adj_TranscriptSales + Adj_VHSSales + Adj_AudioTapeSales

		
	truncate table Marketing.DMSOUPByFormatIgnoreReturns
    
	insert into Marketing.DMSOUPByFormatIgnoreReturns
    select * from staging.TempDMSOUPByFormatIgnoreReturns (nolock)
    
	truncate table staging.TempDMSOUPByFormatIgnoreReturns


END
GO
