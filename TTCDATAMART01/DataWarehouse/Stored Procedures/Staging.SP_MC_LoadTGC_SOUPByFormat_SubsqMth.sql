SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Staging].[SP_MC_LoadTGC_SOUPByFormat_SubsqMth]
	@AsOfDate date = null
AS
BEGIN
	set nocount on
    set @AsOfDate = isnull(@AsOfDate, dateadd(month,-1,getdate()))  
	
	select @AsOfDate  as AsOfDate
    
	if object_id('Staging.MC_TGC_SOUPByFormat_SubsqMthTEMP') is not null drop table Staging.MC_TGC_SOUPByFormat_SubsqMthTEMP

	select CustomerID,
		@AsOfDate as AsOfDate,
		count(OrderID) as Orders,
		sum(NetOrderAmount) as NetOrderAmount,
		sum(ShippingCharge) as ShippingCharge,
		sum(DiscountAmount) as DiscountAmount,
		sum(Tax) as Tax,
		sum(CDSales) as CDSales,
		sum(CDUnits) as CDUnits,
		sum(CDParts) as CDParts,
		sum(DVDSales) as DVDSales,
		sum(DVDUnits) as DVDUnits,
		sum(DVDParts) as DVDParts,
		sum(AudioTapeSales) as AudioTapeSales,
		sum(AudioTapeUnits) as AudioTapeUnits,
		sum(AudioTapeParts) as AudioTapeParts,
		sum(VHSSales) as VHSSales,
		sum(VHSUnits) as VHSUnits,
		sum(VHSParts) as VHSParts,
		sum(AudioDLSales) as AudioDLSales,
		sum(AudioDLUnits) as AudioDLUnits,
		sum(AudioDLParts) as AudioDLParts,
		sum(VideoDLSales) as VideoDLSales,
		sum(VideoDLUnits) as VideoDLUnits,
		sum(VideoDLParts) as VideoDLParts,
		sum(TranscriptSales) as TranscriptSales,
		sum(TranscriptUnits) as TranscriptUnits,
		sum(TranscriptParts) as TranscriptParts,
		sum(DigitalTranscriptSales) as DigitalTranscriptSales,
		sum(DigitalTranscriptUnits) as DigitalTranscriptUnits,
		sum(DigitalTranscriptParts) as DigitalTranscriptParts,
		sum(DigitalSales) as DigitalSales,
		sum(DigitalUnits) as DigitalUnits,
		sum(DigitalParts) as DigitalParts,
		sum(PhysicalSales) as PhysicalSales,
		sum(PhysicalUnits) as PhysicalUnits,
		sum(PhysicalParts) as PhysicalParts,
		sum(TotalMerchandizeSales) as TotalMerchandizeSales,
		sum(TotalMerchandizeUnits) as TotalMerchandizeUnits,
		sum(TotalMerchandizeParts) as TotalMerchandizeParts,
		max(convert(int,FlagCD)) as FlagCD,
		max(convert(int,FlagDVD)) as FlagDVD,
		max(convert(int,FlagAudioTape)) as FlagAudioTape,
		max(convert(int,FlagVHS)) as FlagVHS,
		max(convert(int,FlagAudioDL)) as FlagAudioDL,
		max(convert(int,FlagVideoDL)) as FlagVideoDL,
		max(convert(int,FlagTranscript)) as FlagTranscript,
		max(convert(int,FlagDigitalTranscript)) as FlagDigitalTranscript,
		max(convert(int,FlagDigital)) as FlagDigital,
		max(convert(int,FlagPhysical)) as FlagPhysical,
		sum(case when FlagCD = 1 then 1 else 0 end) as CDOrders,
		sum(case when FlagDVD = 1 then 1 else 0 end) as DVDOrders,
		sum(case when FlagAudioTape = 1 then 1 else 0 end) as AudioTapeOrders,
		sum(case when FlagVHS = 1 then 1 else 0 end) as VHSOrders,
		sum(case when FlagAudioDL = 1 then 1 else 0 end) as AudioDLOrders,
		sum(case when FlagVideoDL = 1 then 1 else 0 end) as VideoDLOrders,
		sum(case when FlagTranscript = 1 then 1 else 0 end) as TranscriptOrders,
		sum(case when FlagDigitalTranscript = 1 then 1 else 0 end) as DigitalTranscriptOrders,
		sum(case when FlagDigital = 1 then 1 else 0 end) as DigitalOrders,
		sum(case when FlagPhysical = 1 then 1 else 0 end) as PhysicalOrders,
		sum(Adj_CDSales) as Adj_CDSales,
		sum(Adj_DVDSales) as Adj_DVDSales,
		sum(Adj_AudioTapeSales) as Adj_AudioTapeSales,
		sum(Adj_VHSSales) as Adj_VHSSales,
		sum(Adj_AudioDLSales) as Adj_AudioDLSales,
		sum(Adj_VideoDLSales) as Adj_VideoDLSales,
		sum(Adj_TranscriptSales) as Adj_TranscriptSales,
		sum(Adj_DigitalTranscriptSales) as Adj_DigitalTranscriptSales,
		sum(Adj_DigitalSales) as Adj_DigitalSales,
		sum(Adj_PhysicalSales) as Adj_PhysicalSales,
		sum(Adj_TotalMerchandizeSales) as Adj_TotalMerchandizeSales
	into Staging.MC_TGC_SOUPByFormat_SubsqMthTEMP
	from Marketing.DMSOUPByFormatIgnoreReturns
	where cast(DateOrdered as date) >= @AsOfDate AND cast(DateOrdered as date) < DATEADD(MM, 1, @AsOfDate) 
	and NetOrderAmount < 1500
	group by Customerid						

		
	-- delete if AsOfDate is already in the table 
	if object_id('Staging.MC_TGC_SOUPByFormat_SubsqMthTEMP') is not null truncate table Staging.MC_TGC_SOUPByFormat_SubsqMthTEMP
	
	insert into Marketing.MC_TGC_SOUPByFormat_SubsqMth
	select * 
	--into Marketing.MC_TGC_SOUPByFormat_SubsqMth
	from Staging.MC_TGC_SOUPByFormat_SubsqMthTEMP


end



GO
