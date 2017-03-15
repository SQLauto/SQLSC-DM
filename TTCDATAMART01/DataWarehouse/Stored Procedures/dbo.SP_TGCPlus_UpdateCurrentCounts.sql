SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_TGCPlus_UpdateCurrentCounts] @TGCPlusTableName varchar(100)
As
Begin

--Declare @TGCPlusTableName varchar(100) = 'TGCPlus_Film'
Declare @SQL Nvarchar(1000)
set @SQL = '

Declare @CurrentCounts varchar(10)
select @CurrentCounts = count(*) from DataWarehouse.Archive.' + @TGCPlusTableName + '
select @CurrentCounts

Update Mapping.TGCplus_QC
set CurrentCounts = @CurrentCounts , 
	UpdatedCurrentCounts = 1,
	LastUpdatedDate = getdate()
where TGCPlusTableName=  '''+ @TGCPlusTableName +''''

print @SQL
Exec (@SQL)


select * from Mapping.TGCplus_QC
order by LastUpdatedDate desc

End
GO
