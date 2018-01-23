SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_SMR_AmazonSVOD] as
Select
CS.Platform,
CS.ReportDate,
CS.course_id, 
CS.SM, 
DMC.CourseName, DMC.PrimaryWebCategory, DMC.PlusGenre, 
DPSAgg.DpS, DPSAgg.OverallRevenue
from
(
select 
'AmazonSVOD' as Platform, 
ReportDate, 
courseid as course_id,
sum(total_number_of_minutes_streamed) SM
from archive.Amazon_streaming (nolock)
group by Reportdate, courseid
) as CS
left join
(
Select Revenue.ReportDate, (Revenue.Amount/Streaming.SM) DpS, Revenue.Amount as OverallRevenue
from
(
Select ReportDate, sum(Amount) Amount
from
(
select 
ReportDate, 
case 
	when CurrencyCode = 'USD' then NetPayment
	when CurrencyCode = 'GBP' then (1.35 * NetPayment)
	else 0 end as Amount, 
CurrencyCode, Category, NetPayment from archive.amazon_payment (nolock)
where Category = 'Paid' 
) as agg
group by ReportDate 
) as Revenue
	left join
(
select ReportDate, sum(total_number_of_minutes_streamed) SM from archive.amazon_streaming (nolock)
group by ReportDate
) as Streaming on Revenue.ReportDate = Streaming.ReportDate
) as DPSAgg on CS.ReportDate = DPSAgg.ReportDate
	left join
(select distinct CourseID, CourseName, PrimaryWebCategory, TGCPlusSubjectCategory as PlusGenre From staging.vw_Dmcourse (nolock) where BundleFlag = 0) as DMC on CS.Course_ID = DMC.CourseID
; 
GO
