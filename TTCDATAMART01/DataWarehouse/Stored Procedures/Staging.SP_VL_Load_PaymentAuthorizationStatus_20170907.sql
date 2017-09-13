SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [Staging].[SP_VL_Load_PaymentAuthorizationStatus_20170907]    
AS    
BEGIN    
    

/*Update Previous Counts*/
EXEC SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCPlus_PaymentAuthorizationStatus'

    
/*Truncate and Load */    
--Truncate table [Archive].[TGCPlus_PaymentAuthorizationStatus]    
  
/*     
insert into [Archive].[TGCPlus_PaymentAuthorizationStatus]     
 (pa_id,pa_user_id,pas_id,pas_version,pas_created_at,pas_plan_id,pas_state,pas_updated_at,pas_uuid,pas_payment_handler,pas_subscribed_via_platform,DMLastUpdateESTDateTime)    
     
     
select     
Cast(pa_id as BigInt) pa_id,Cast(pa_user_id as BigInt) pa_user_id,pas_id,Cast(pas_version as BigInt) pas_version,Cast(pas_created_at as DateTime) pas_created_at    
,pas_plan_id,pas_state,Cast(pas_updated_at as DateTime) pas_updated_at,pas_uuid,pas_payment_handler,pas_subscribed_via_platform,  GETDATE() as DMLastUpdateESTDateTime     
from [Staging].VL_ssis_PaymentAuthorizationStatus    
*/    
    
/*Deletes*/    
/*    
Delete from [Archive].[TGCPlus_PaymentAuthorizationStatus]     
where pas_created_at >= (select Min(Cast(pas_created_at as DateTime)) as pas_created_at from [Staging].VL_ssis_PaymentAuthorizationStatus)    
*/  

/*Temp data fix due to duplicates in 8/5/2016 */
  --Delete S from [Staging].VL_ssis_PaymentAuthorizationStatus  S
  --where cast(pas_updated_at as date)<='8/6/2016'

/* Load Distinct Values*/   
SELECT DISTINCT * INTO #DistinctPAS FROM [Staging].VL_ssis_PaymentAuthorizationStatus 
TRUNCATE TABLE [Staging].VL_ssis_PaymentAuthorizationStatus 
INSERT INTO [Staging].VL_ssis_PaymentAuthorizationStatus 
SELECT * FROM #DistinctPAS
    
DELETE A FROM [Archive].[TGCPlus_PaymentAuthorizationStatus] A  
INNER JOIN [Staging].VL_ssis_PaymentAuthorizationStatus  S  
ON a.pas_id = s.pas_id  
WHERE A.pas_id NOT IN ( SELECT pas_id FROM [Staging].VL_ssis_PaymentAuthorizationStatus GROUP BY pas_id HAVING COUNT(*)>1)  /*Added code to not delete duplicates again VB 2/27/2017*/
  
/*Inserts*/    
    
INSERT INTO [Archive].[TGCPlus_PaymentAuthorizationStatus]     
 (pa_id,pa_user_id,pas_id,pas_version,pas_created_at,pas_plan_id,pas_state,pas_updated_at,pas_uuid,pas_payment_handler,pas_subscribed_via_platform,DMLastUpdateESTDateTime)    
    
SELECT  DISTINCT  
CAST(pa_id AS BIGINT) pa_id,CAST(pa_user_id AS BIGINT) pa_user_id,pas_id,CAST(pas_version AS BIGINT) pas_version,CAST(pas_created_at AS DATETIME) pas_created_at    
,pas_plan_id,pas_state,CAST(pas_updated_at AS DATETIME) pas_updated_at,pas_uuid,pas_payment_handler,pas_subscribed_via_platform,  GETDATE() AS DMLastUpdateESTDateTime     
FROM [Staging].VL_ssis_PaymentAuthorizationStatus 
WHERE pas_id NOT IN ( SELECT pas_id FROM [Staging].VL_ssis_PaymentAuthorizationStatus GROUP BY pas_id HAVING COUNT(*)>1)

IF EXISTS (SELECT pas_id FROM [Staging].VL_ssis_PaymentAuthorizationStatus GROUP BY pas_id HAVING COUNT(*)>1)
BEGIN 

DECLARE @Pas_ids VARCHAR(1000) = '',  @Message VARCHAR(2000) = ''
SELECT @Pas_ids = @Pas_ids +  CAST(pas_id AS VARCHAR(10)) + ',' FROM [Staging].VL_ssis_PaymentAuthorizationStatus GROUP BY pas_id HAVING COUNT(*)>1 
SET  @Pas_ids  = SUBSTRING(@Pas_ids,1,LEN(@Pas_ids)-1)
SET  @Message = REPLACE('Check the below table <b> SELECT * FROM [Staging].VL_ssis_PaymentAuthorizationStatus where pas_id in (<pas_id>) </b>', '<pas_id>',@Pas_ids) 

		DECLARE @p_body AS NVARCHAR(MAX), @p_subject AS NVARCHAR(MAX)
		DECLARE @p_recipients AS NVARCHAR(MAX), @p_profile_name AS NVARCHAR(MAX)
		SET @p_profile_name = N'DL datamart alerts'
		SET @p_recipients = N'~dldatamartalerts@TEACHCO.com'
		SET @p_subject = N'Duplicate values in Staging.VL_ssis_PaymentAuthorizationStatus table '
		SET @p_body = @Message
		EXEC msdb.dbo.sp_send_dbmail
		  @profile_name = @p_profile_name,
		  @recipients = @p_recipients,
		  @body = @p_body,
		  @body_format = 'HTML',
		  @subject = @p_subject,
		  @importance = 'High'
		  

END

    

/*Update Counts*/
EXEC SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCPlus_PaymentAuthorizationStatus'
    
END 

GO
