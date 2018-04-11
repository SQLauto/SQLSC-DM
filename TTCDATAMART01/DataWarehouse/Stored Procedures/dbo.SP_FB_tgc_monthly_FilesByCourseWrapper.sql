SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Proc [dbo].[SP_FB_tgc_monthly_FilesByCourseWrapper]    
as    
Begin    
    
  
	exec [dbo].[SP_FB_TGC_FilesByCourse] 1050,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 1406,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 1707,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 1846,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 1908,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 1933,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 2541,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 2810,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 2840,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 3810,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 5724,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 7770,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 7776,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 7782,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 7901,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 7923,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 8241,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 8525,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 9151,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 9231,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 9411,'Digital only','ALL'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 9631,'Digital only','ALL'

	exec [dbo].[SP_FB_TGC_FilesByCourse] 1050,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 1406,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 1707,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 1846,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 1908,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 1933,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 2541,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 2810,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 2840,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 3810,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 5724,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 7770,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 7776,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 7782,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 7901,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 7923,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 8241,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 8525,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 9151,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 9231,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 9411,'Digital only','ALL','Facebook'
	exec [dbo].[SP_FB_TGC_FilesByCourse] 9631,'Digital only','ALL','Facebook'


	insert into archive.TGC_FBFiles_ByCourse
	SELECT 
		FileName = t.NAME + 'FNL.txt',
	   -- TableSchema = s.Name,
		RowCounts = p.rows,
		CreateDate = cast(t.create_date as date)
	FROM 
		rfm.sys.tables t
	INNER JOIN 
		rfm.sys.schemas s ON t.schema_id = s.schema_id
	INNER JOIN      
		rfm.sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN 
		rfm.sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	WHERE t.is_ms_shipped = 0
		and t.name like 'FB_TGC_File_%'
		and t.create_date >= cast(getdate() as date)
	GROUP BY
		t.NAME, s.Name, p.Rows, t.create_date
	ORDER BY 
		s.Name, t.Name
    
    
--DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(max)    
--DECLARE @p_recipients as nvarchar(max), @p_profile_name as nvarchar(max)    
--SET @p_profile_name = N'DL datamart alerts'    
--SET @p_recipients = N'~dldatamartalerts@TEACHCO.com'    
--SET @p_subject = N'FaceBook Monthly Report'    
--SET @p_body = '<b>Facebook Monthly Report has been created</b>.      
--let others know that the report is ready here ' + @Dest + '    
    
--For Report Run the below:    
--Select * from rfm..FbTgcplusMonthlyReport    
    
--'    
--EXEC msdb.dbo.sp_send_dbmail    
--  @profile_name = @p_profile_name,    
--  @recipients = @p_recipients,    
--  @body = @p_body,    
--  @body_format = 'HTML',    
--  @subject = @p_subject    
    
    
End    
    
GO
