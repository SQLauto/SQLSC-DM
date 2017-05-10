SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 CREATE Proc [Staging].[SP_Load_Stripe_transactions]
 as

 Begin

  BEGIN TRY
    BEGIN TRANSACTION

	Print 'Staging Counts'
	select  id,Cast(Description as varchar(255))as Description,dbo.GMTToLocalDateTime(cast(created as datetime))as created,cast(Amount as float)as Amount,cast(AmountRefunded as float)as AmountRefunded, Cast(Currency as varchar(10))as Currency
	, cast(ConvertedAmount as float)as ConvertedAmount,  cast(ConvertedAmountRefunded as float)as ConvertedAmountRefunded,cast(Fee as float)as Fee,cast(Tax as float)as Tax, Cast(ConvertedCurrency as varchar(10))as ConvertedCurrency, cast(Mode as varchar(10))as Mode
	, cast(Status as varchar(10))as Status, cast(StatementDescriptor as varchar(20))as StatementDescriptor, cast(CustomerID as varchar(50))as CustomerID, cast(CustomerDescription as varchar(255))as CustomerDescription
	, cast(CustomerEmail as varchar(100))as CustomerEmail, cast(Captured as varchar(10))as Captured, cast(CardID as varchar(100))as CardID, cast(CardLast4 as varchar(4))as CardLast4
	, cast(CardBrand as varchar(20))as CardBrand, cast(CardFunding as varchar(10))as CardFunding, cast(CardExpMonth as varchar(2))as CardExpMonth
	, cast(CardExpYear as varchar(4))as CardExpYear, cast(CardName as varchar(50))as CardName, cast(CardAddressLine1 as varchar(255))as CardAddressLine1, cast(CardAddressLine2 as varchar(255))as CardAddressLine2
	, cast(CardAddressCity as varchar(50))as CardAddressCity,cast(CardAddressState as varchar(50))as CardAddressState,cast(CardAddressCountry as varchar(50))as CardAddressCountry,cast(CardAddressZip as varchar(20))as CardAddressZip
	, cast(CardIssueCountry as varchar(10))as CardIssueCountry,cast(CardFingerprint as varchar(50))as CardFingerprint,cast(CardCVCStatus as varchar(50))as CardCVCStatus,cast(CardAVSZipStatus as varchar(50))as CardAVSZipStatus
	, cast(CardAVSLine1Status as varchar(50))as CardAVSLine1Status,cast(CardTokenizationMethod as varchar(50))as CardTokenizationMethod, cast(DisputedAmount as float)DisputedAmount,cast(DisputeStatus as varchar(50))as DisputeStatus
	, cast(DisputeReason as varchar(50))as DisputeReason,dbo.GMTToLocalDateTime(cast( case when DisputeDate = '' then null else DisputeDate end as datetime))as DisputeDate, cast(DisputeEvidenceDue as varchar(50))as DisputeEvidenceDue,cast(InvoiceID as varchar(50))as InvoiceID
	, cast(PaymentSourceType as varchar(10))as PaymentSourceType,cast(Destination as varchar(50))as Destination,cast(Transfer as varchar(50))as Transfer,cast(TransferGroup as varchar(50))as TransferGroup
	, cast(userId_metadata as varchar(255))as userId_metadata,cast(taxAmount_metadata as float )as taxAmount_metadata,cast(siteName_metadata as varchar(10))as siteName_metadata,cast(siteId_metadata as varchar(255))as siteId_metadata
	, cast(preTaxAmount_metadata as float)as preTaxAmount_metadata,cast(captureReferenceId_metadata as varchar(255))as captureReferenceId_metadata,cast(subscriptionPlanId_metadata as varchar(255))as subscriptionPlanId_metadata
	, cast(subscriptionPlanIdentifier_metadata as varchar(255))as subscriptionPlanIdentifier_metadata,cast(userEmail_metadata as varchar(100))as userEmail_metadata 
	, Getdate() as DMLastupdated
	into #Stripe
	from staging.[Stripe_ssis_transactions]

	
	Print 'Deletes'

	Delete A from  Archive.Stripe_transactions A 
	join #Stripe S on A.id =  S.id

	Print 'Inserts'

	Insert into Archive.Stripe_transactions
	select * from #Stripe

    COMMIT TRANSACTION

  END TRY

  BEGIN CATCH
    IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
 
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
 
    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH

  
 END
GO
