SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_TGCPlus_UpdatePreviousCounts] @TGCPlusTableName varchar(100)
As
Begin

Update mapping.TGCplus_QC
set Previous2DaysCounts = Previous1DaysCounts, 
	Previous1DaysCounts = CurrentCounts,   
	UpdatedPeviousCounts = 1,
	UpdatedCurrentCounts = 0,
	LastUpdatedDate = getdate()
where TGCPlusTableName=@TGCPlusTableName

select * from Mapping.TGCplus_QC
order by LastUpdatedDate desc
End
GO
