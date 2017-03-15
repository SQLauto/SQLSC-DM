SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_DailyQC_file]  
as  
Begin  
select table_name,	row_count,	col_count,	cast (data_size	as nvarchar(20)) as data_size,ReportDate,	row_count_diff,	new_table_flag,	LastReportDate  
from Datawarehouse.archive.DAXImportTableQC   
where row_count_diff<=0 
--and new_table_flag = 0
 
order by table_name  
End
GO
