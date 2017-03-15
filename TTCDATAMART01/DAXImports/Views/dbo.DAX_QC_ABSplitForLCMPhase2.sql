SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [dbo].[DAX_QC_ABSplitForLCMPhase2]
AS
    
	
select CAST(createddatetime as date) CreatedDate,	
	 SPLITNAME, SPLITASSIGNED, RIGHT(accountnum,1) OddOREven,	
	 COUNT(accountNum) CustomerCount,
	 GETDATE() as ReportDate
from DAX_TTCMKTCUSTOMEROFFERSINTERNAL	
where SPLITNAME = 'T12_201305NewCust'	
group by CAST(createddatetime as date),	
	SPLITNAME, SPLITASSIGNED, RIGHT(accountnum,1) 


GO
