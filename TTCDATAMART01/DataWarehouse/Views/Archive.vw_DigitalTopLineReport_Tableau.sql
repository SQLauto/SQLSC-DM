SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_DigitalTopLineReport_Tableau] as
select 
DateOrdered,
MD_Audience,
MD_Channel,
OrderSource, CountryCode, 
ReportDate,
AgeBin, Gender, HouseholdIncomeBin, Education, 
sum(isnull(DVDSales,0)) as DVDSales,
sum(isnull(CDSales,0)) as CDSales,
sum(isnull(VideoDLSales,0)) as VideoDLSales,
sum(isnull(AudioDLSales,0)) as AudioDLSales,
sum(isnull(TranscriptSales,0)) as TranscriptSales,
sum(isnull(DigitalTranscriptSales,0)) as DigitalTranscriptSales,
sum(isnull(DVDSales,0))+sum(isnull(CDSales,0))+sum(isnull(VideoDLSales,0))+sum(isnull(AudioDLSales,0))+sum(isnull(TranscriptSales,0))+sum(isnull(DigitalTranscriptSales,0)) as [Total Sales],
sum(isnull(DVDSales,0))+sum(isnull(CDSales,0))+sum(isnull(VideoDLSales,0))+sum(isnull(AudioDLSales,0))+sum(isnull(TranscriptSales,0))+sum(isnull(DigitalTranscriptSales,0))+sum(isnull(ShippingCharge,0))+sum(isnull(DiscountAmount,0)) as [Total Sales with S&H],
isnull(
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+(sum(Isnull(TranscriptSales,0)))) = 0 then null
	else sum(Isnull(DVDSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(isnull(DigitalTranscriptSales,0)))))+sum(Isnull(DVDSales,0))*(sum(Isnull(ShippingCharge,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(TranscriptSales,0))))
	end, 0) as FinalDVDSales,
isnull(case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+(sum(Isnull(TranscriptSales,0)))) = 0 then null
	else sum(Isnull(CDSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(isnull(DigitalTranscriptSales,0)))))+sum(Isnull(CDSales,0))*(sum(Isnull(ShippingCharge,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(TranscriptSales,0))))
	end,0) as FinalCDSales,
isnull(case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+(sum(Isnull(TranscriptSales,0)))) = 0 then null
	else sum(Isnull(TranscriptSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(isnull(DigitalTranscriptSales,0)))))+sum(Isnull(TranscriptSales,0))*(sum(Isnull(ShippingCharge,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(TranscriptSales,0))))
	end,0) as FinalTranscriptSales,
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))) = 0 then null
	else sum(Isnull(VideoDLSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))))) 
end as FinalVDL,
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))) = 0 then null
	else sum(Isnull(AudioDLSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))))) 
end as FinalADL,
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))) = 0 then null
	else sum(Isnull(DigitalTranscriptSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))))) 
end as FinalDT,

isnull(
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+(sum(Isnull(TranscriptSales,0)))) = 0 then null
	else sum(Isnull(DVDSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(isnull(DigitalTranscriptSales,0)))))+sum(Isnull(DVDSales,0))*(sum(Isnull(ShippingCharge,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(TranscriptSales,0))))
	end, 0) 
+
isnull(case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+(sum(Isnull(TranscriptSales,0)))) = 0 then null
	else sum(Isnull(CDSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(isnull(DigitalTranscriptSales,0)))))+sum(Isnull(CDSales,0))*(sum(Isnull(ShippingCharge,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(TranscriptSales,0))))
	end,0)
+
isnull(case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+(sum(Isnull(TranscriptSales,0)))) = 0 then null
	else sum(Isnull(TranscriptSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(isnull(DigitalTranscriptSales,0)))))+sum(Isnull(TranscriptSales,0))*(sum(Isnull(ShippingCharge,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(TranscriptSales,0))))
	end,0)  as FinalPhysicalSales,

(
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))) = 0 then null
	else sum(Isnull(VideoDLSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))))) 
end 
)
+
(
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))) = 0 then null
	else sum(Isnull(AudioDLSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))))) 
end 
)
+
(
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))) = 0 then null
	else sum(Isnull(DigitalTranscriptSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))))) 
end 
) as FinalDigitalSales,
isnull(
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+(sum(Isnull(TranscriptSales,0)))) = 0 then null
	else sum(Isnull(DVDSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(isnull(DigitalTranscriptSales,0)))))+sum(Isnull(DVDSales,0))*(sum(Isnull(ShippingCharge,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(TranscriptSales,0))))
	end, 0) 
+
isnull(case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+(sum(Isnull(TranscriptSales,0)))) = 0 then null
	else sum(Isnull(CDSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(isnull(DigitalTranscriptSales,0)))))+sum(Isnull(CDSales,0))*(sum(Isnull(ShippingCharge,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(TranscriptSales,0))))
	end,0)
+
isnull(case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+(sum(Isnull(TranscriptSales,0)))) = 0 then null
	else sum(Isnull(TranscriptSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(isnull(DigitalTranscriptSales,0)))))+sum(Isnull(TranscriptSales,0))*(sum(Isnull(ShippingCharge,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(TranscriptSales,0))))
	end,0) 
+

(
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))) = 0 then null
	else sum(Isnull(VideoDLSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))))) 
end 
)
+
(
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))) = 0 then null
	else sum(Isnull(AudioDLSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))))) 
end 
)
+
(
case	
	when (sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))) = 0 then null
	else sum(Isnull(DigitalTranscriptSales,0))*(1+(sum(Isnull(DiscountAmount,0))/(sum(Isnull(DVDSales,0))+sum(Isnull(CDSales,0))+sum(Isnull(VideoDLSales,0))+sum(Isnull(AudioDLSales,0))+sum(Isnull(TranscriptSales,0))+sum(Isnull(DigitalTranscriptSales,0))))) 
end 
) as FinalSales
from marketing.DailyToplineReport (nolock)
where
--DateOrdered >= cast(dateadd(day, -1, GetDate()) as Date) 
DateOrdered < cast(GetDate() as Date)
group by DateOrdered, MD_Audience, MD_Channel, OrderSource, CountryCode, 
ReportDate,
AgeBin, Gender, HouseholdIncomeBin, Education;
GO
