SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [Staging].[SP_CTMonitor_Load_CallSummary]
as

BEGIN

  BEGIN TRY
  
    BEGIN TRANSACTION


	Delete A from datawarehouse.Archive.CTMonitor_CallSummary  A
	join datawarehouse.staging.CTMonitor_ssis_CallSummary S
	on A.CallSummaryId = S.CallSummaryId


	 insert into datawarehouse.Archive.CTMonitor_CallSummary 
					(CallSummaryId,SwitchId,CallDirectionId,AlertingDateTime,CallStartDateTime,CallQueuedDateTime,CallAnswerDateTime,CallEndDateTime,AlertingNumber,
					CallFromNumber,CallToNumber,TrunkGroupDeviceId,TrunkGroupMemberId,SplitDeviceId,EnteredCodeData,EnteredCodeVDN,DistributingDevice,DistributingVDN,
					UserData,UCID,NewUCID,OldUCID,Abandon,CallId,PrimaryCallId,SecondaryCallId,Agent1DeviceId,Station1DeviceId,Agent2DeviceId,Station2DeviceId,Call2Type,
					Agent3DeviceId,Station3DeviceId,Call3Type,Agent4DeviceId,Station4DeviceId,Call4Type,Agent5DeviceId,Station5DeviceId,Call5Type,Agent6DeviceId,Station6DeviceId,Call6Type)
	
		select CallSummaryId,SwitchId,CallDirectionId,dbo.GMTToLocalDateTime(AlertingDateTime) as AlertingDateTime,dbo.GMTToLocalDateTime(CallStartDateTime) as CallStartDateTime,
		dbo.GMTToLocalDateTime(CallQueuedDateTime) as CallQueuedDateTime,dbo.GMTToLocalDateTime(CallAnswerDateTime) as CallAnswerDateTime,dbo.GMTToLocalDateTime(CallEndDateTime) as CallEndDateTime,
		AlertingNumber,		CallFromNumber,CallToNumber,TrunkGroupDeviceId,TrunkGroupMemberId,SplitDeviceId,EnteredCodeData,EnteredCodeVDN,DistributingDevice,DistributingVDN,
		UserData,UCID,NewUCID,OldUCID,Abandon,CallId,PrimaryCallId,SecondaryCallId,Agent1DeviceId,Station1DeviceId,Agent2DeviceId,Station2DeviceId,Call2Type,
		Agent3DeviceId,Station3DeviceId,Call3Type,Agent4DeviceId,Station4DeviceId,Call4Type,Agent5DeviceId,Station5DeviceId,Call5Type,Agent6DeviceId,Station6DeviceId,Call6Type
		from datawarehouse.staging.CTMonitor_ssis_CallSummary 


    COMMIT TRANSACTION
  
  END TRY
  
  
  BEGIN CATCH
    IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION
 
    DECLARE @ErrorNumber INT = ERROR_NUMBER()
    DECLARE @ErrorLine INT = ERROR_LINE()
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
    DECLARE @ErrorState INT = ERROR_STATE()
 
    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10))
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10))
 
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
  
  END CATCH


END
GO
