SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[SP_MC_TGCPlus_Mapping]
as
select CustomerID as TGC_Customerid ,TGCP_ID as TGCPlus_Customerid , rank () over ( partition by customerid order by LastUpdatedDate) as rnk, min(LastUpdatedDate) as MatchDate into #pluscustomers
from DataWarehouse.mapping.TGC_TGCplus group by CustomerID,TGCP_ID,LastUpdatedDate




select b.MatchDate MatchDate, AsofDate, b.TGC_Customerid as CustomerID  ,IntlSubType, PaidFlag AS FlagPlusStatus, IntlSubPaymentHandler as PaymentHandler ,LTDPaidAmt,
CASE WHEN LTDPaidAmt BETWEEN 0 AND 10 THEN '1: $1-10'
 WHEN LTDPaidAmt BETWEEN 11  AND 20 THEN '2: $11-20'
 WHEN LTDPaidAmt BETWEEN 21 AND 30 THEN '3: $21-30'
 WHEN LTDPaidAmt BETWEEN 31 AND 40 THEN '4: $31-40'
 WHEN LTDPaidAmt BETWEEN 41 AND 50 THEN '5: $41-50'
 WHEN LTDPaidAmt BETWEEN 51 AND 60 THEN '6: $51-60'
  WHEN LTDPaidAmt BETWEEN 61 AND 70 THEN '7: $61-70'
 WHEN LTDPaidAmt BETWEEN 71 AND 80 THEN '8: $71-80'
 WHEN LTDPaidAmt BETWEEN 81 AND 90 THEN '9: $81-90'
 WHEN LTDPaidAmt BETWEEN 91 AND 100 THEN '10: $91-100'
 WHEN LTDPaidAmt BETWEEN 101 AND 110 THEN '11: $101-110'
 WHEN LTDPaidAmt BETWEEN 111 AND 120 THEN '12: $111-120'
 WHEN LTDPaidAmt BETWEEN 121 AND 130 THEN '13: $121-130'
 WHEN LTDPaidAmt BETWEEN 131 AND 140 THEN '14: $131-140'
 WHEN LTDPaidAmt BETWEEN 141 AND 150 THEN '15: $141-150'
 WHEN LTDPaidAmt BETWEEN 151 AND 160 THEN '16: $151-160'
 WHEN LTDPaidAmt BETWEEN 161 AND 170 THEN '17: $161-170'
 WHEN LTDPaidAmt BETWEEN 171 AND 180 THEN '18: $171-180'
 WHEN LTDPaidAmt BETWEEN 181 AND 190 THEN '19: $181-190'
 WHEN LTDPaidAmt BETWEEN 191 AND 200 THEN '20: $191-200'
 WHEN LTDPaidAmt > 200 THEN '21: $200+' 
ELSE '0: $0' END AS LTDPaidAmtBins

INTO #TEMP
from [DataWarehouse].[Marketing].[TGCPlus_CustomerSignature_Snapshot] a join
#pluscustomers b
on a.customerid=b.TGCPlus_Customerid where b.rnk = 1 and AsofDate > b.MatchDate
 
order by AsofDate





TRUNCATE TABLE Mapping.MC_TGCPlus_Customers


INSERT INTO Mapping.MC_TGCPlus_Customers SELECT * FROM #TEMP




 select  min(merge_date) as AsOfDate,acctno as TGC_Customerid, FBACustomerid into #FBA
 from Datawarehouse.mapping.FBA_Merge_Dupes group by acctno, FBACustomerid
 order by AsOfDate


Truncate table MAPPING.MC_FBA_Customers

insert  INTO MAPPING.MC_FBA_Customers select * from #FBA order by AsOfDate


drop table #temp
GO
