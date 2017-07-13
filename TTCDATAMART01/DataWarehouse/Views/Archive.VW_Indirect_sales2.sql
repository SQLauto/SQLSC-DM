SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 CREATE View [Archive].[VW_Indirect_sales2]
 as
 
 /*
 select DISTINCT CountryCode,
		PartnerName,
		ReportDate,
		Format,
		ReleaseDate,
		CourseID,
		LectureNumber,
		Units,
		round(Revenue,2)Revenue,
		PurchaseChannel 
 from Archive.Indirect_Sales
 */

  select CountryCode,
		 PartnerName,
		 ReportDate,
		 Format,
		 ReleaseDate,
		 CourseID,
		 LectureNumber,
		 Units,
		 round(Revenue,2)Revenue,
		 PurchaseChannel,
		 Library,
		 State,	
		 PostalCode
  from Archive.Indirect_Sales2

 Union All


     SELECT 'US' as CountryCode, 
       case when b2b.adcode = 104961 then 'Recorded Books'
			when b2b.adcode = 97390  then 'NatGeo' end as PartnerName, 
       cast(Dateadd(s, -1, Dateadd(mm, Datediff(m, 0, dateordered), 0)) as date)Reportdate, 
       CASE 
         WHEN mediatypeid = 'DownloadA' THEN 'Digital Audio' 
         WHEN mediatypeid = 'DVD' THEN 'DVD' 
         WHEN mediatypeid = 'CD' THEN 'CD' 
         WHEN mediatypeid = 'DownloadA' THEN 'Digital Audio' 
         WHEN mediatypeid = 'DownloadV' THEN 'Digital Video' 
         WHEN mediatypeid = 'Transcript' THEN 'Transcript'
		 --WHEN mediatypeid = 'Printed' THEN 'Printed'  
         ELSE 'Other' END as Format,  
		 Null as ReleaseDate,
       courseid, 
       NULL AS LectureNumber, 
       Cast(Sum(o.quantity) AS INT) as Units, 
       Round(Sum(o.salesprice * o.quantity) ,2) as Revenue, 
       NULL AS PurchaseChannel,
	   NULL AS Library,
	   NULL AS State,
	   NULL AS PostalCode
FROM   datawarehouse.marketing.b2bsales b2b (nolock) 
       JOIN daximports..dax_orderitemexport O (nolock) 
         ON b2b.orderid = O.orderid 
       JOIN datawarehouse.staging.invitem i (nolock) 
         ON i.stockitemid = O.itemid 
WHERE  b2b.adcode in (104961, 97390  )
       AND I.mediatypeid NOT IN ( 'StreamA', 'StreamV' ) 
	   and I.ItemCategoryID not in ('Coupon' ,'GiftCert','Promotion','NA')    
GROUP  BY case when b2b.adcode =104961 then 'Recorded Books'
			  when b2b.adcode = 97390  then'NatGeo' end
		,cast(Dateadd(s, -1, Dateadd(mm, Datediff(m, 0, dateordered), 0)) as date), 
          courseid, 
          CASE 
            WHEN mediatypeid = 'DownloadA' THEN 'Digital Audio' 
            WHEN mediatypeid = 'DVD' THEN 'DVD' 
            WHEN mediatypeid = 'CD' THEN 'CD' 
            WHEN mediatypeid = 'DownloadA' THEN 'Digital Audio' 
            WHEN mediatypeid = 'DownloadV' THEN 'Digital Video' 
            WHEN mediatypeid = 'Transcript' THEN 'Transcript' 
			--WHEN mediatypeid = 'Printed' THEN 'Printed' 
            ELSE 'Other' 
          END 
GO
