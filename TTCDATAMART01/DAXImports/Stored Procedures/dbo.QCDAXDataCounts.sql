SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[QCDAXDataCounts] 
AS
	-- Preethi Ramanujam    3/11/2013 -- To QC dax table counts
	-- Vikram Bondugula  02/17/2015  -- Add new table and updates to calculate difference
begin

CREATE TABLE #temp (
                table_name sysname ,
                row_count INT,
                reserved_size VARCHAR(50),
                data_size VARCHAR(50),
                index_size VARCHAR(50),
                unused_size VARCHAR(50))
SET NOCOUNT ON
INSERT     #temp
    EXEC       sp_msforeachtable 'sp_spaceused "?"'



--Comment the below insert INTO Datawarehouse.archive.DAXImportTableQC1 in future after few tests.
    
Insert into Datawarehouse.archive.DAXImportTableQC1     
SELECT  a.table_name,
        a.row_count,
        COUNT(*) AS col_count,
        a.data_size,
        GETDATE() as ReportDate           
FROM  #temp a
        INNER JOIN information_schema.columns b
        ON a.table_name collate database_default = b.table_name collate database_default
WHERE a.table_name not like 'sysdiagrams'
GROUP BY   a.table_name, a.row_count, a.data_size
ORDER BY   CAST(REPLACE(a.data_size, 'KB', '') AS integer) DESC


--------------- Update table with count differences ----------------------

UPDATE qc
set  qc.row_count = a.row_count,
	 qc.row_count_diff = a.row_count - isnull(qc.row_count,0),
	 qc.ReportDate = a.ReportDate,
	 qc.new_table_flag = 0,
	 qc.LastReportDate = qc.ReportDate

from 
	(SELECT  a.table_name,
			 a.row_count,
			 COUNT(*) AS col_count,
			 a.data_size,
			 GETDATE() as ReportDate           
	FROM  #temp a
			INNER JOIN information_schema.columns b
			ON a.table_name collate database_default = b.table_name collate database_default
			WHERE a.table_name not like 'sysdiagrams'
			GROUP BY   a.table_name, a.row_count, a.data_size
	) A
    inner join Datawarehouse.archive.DAXImportTableQC qc (nolock)
    on qc.table_name=a.table_name


--------- Add new tables for next day QC ---------------

Insert into Datawarehouse.archive.DAXImportTableQC

	SELECT  a.table_name,
			 a.row_count,
			 COUNT(*) AS col_count,
			 a.data_size,
			 GETDATE() as ReportDate,
			 COUNT(*) AS row_count_diff,
			 1 as new_table_flag,
			 GETDATE() as LastReportDate
	FROM  #temp a
			INNER JOIN information_schema.columns b
			ON a.table_name collate database_default = b.table_name collate database_default
			left join Datawarehouse.archive.DAXImportTableQC qc (nolock)
			on qc.table_name=a.table_name
			WHERE a.table_name not like 'sysdiagrams' and qc.table_name is null
			GROUP BY   a.table_name, a.row_count, a.data_size


DROP TABLE #temp

end

GO
