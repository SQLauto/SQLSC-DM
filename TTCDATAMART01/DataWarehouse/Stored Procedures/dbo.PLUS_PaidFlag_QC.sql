SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PLUS_PaidFlag_QC]

as 

if exists(

SELECT top 1 1 
  FROM [DataWarehouse].[Marketing].[TGCplus_VideoEvents_Smry] 
  where   (Paid_SeqNum is not null and PaidFlag = 0 ) OR
  ( PaidFlag = 1 and Paid_SeqNum is null ) 
 )

 begin 
  DECLARE @p_body3 AS NVARCHAR(MAX), @p_subject3 AS NVARCHAR(MAX)  
  DECLARE @p_recipients3 AS NVARCHAR(MAX), @p_profile_name3 AS NVARCHAR(MAX)  
  SET @p_profile_name3 = N'DL datamart alerts'  
  SET @p_recipients3 = N'~dldatamartalerts@TEACHCO.com'  
  SET @p_subject3 = N'Summary Table PLus Paid Flag Error'  
  SET @p_body3 = 'Paid Flag or PaidSeq are incorrect --  QC Script: SELECT * 
  FROM [DataWarehouse].[Marketing].[TGCplus_VideoEvents_Smry] where   (Paid_SeqNum is not null and PaidFlag = 0 ) OR
 
 ( PaidFlag = 1 and Paid_SeqNum is null )'  
  EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = @p_profile_name3,  
    @recipients = @p_recipients3,  
    @body = @p_body3,  
    @body_format = 'HTML',  
    @subject = @p_subject3 
	
 End 
 
GO
