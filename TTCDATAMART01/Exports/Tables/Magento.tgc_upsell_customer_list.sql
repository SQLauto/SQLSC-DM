CREATE TABLE [Magento].[tgc_upsell_customer_list]
(
[dax_customer_id] [int] NOT NULL,
[location_id] [tinyint] NOT NULL,
[test_rank] [tinyint] NOT NULL,
[list_id] [smallint] NOT NULL,
[Last_Updated_Date] [datetime] NOT NULL CONSTRAINT [DF__tgc_upsel__Last___1273C1CD] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: Updates Last Updated Date field when any of the data is updated
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2277	08/04/2016	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [Magento].[T_Update_Last_Update_Date]
	ON [Magento].[tgc_upsell_customer_list]
	AFTER INSERT,UPDATE
AS
BEGIN
		SET NOCOUNT ON

	-- Error Variables
	DECLARE @error_description VARCHAR(MAX),
		@sp_name VARCHAR(MAX),
		@error_number INT,
		@error_line INT,
		@error_state VARCHAR(MAX),
		@error_severity VARCHAR(MAX),
		@user_name VARCHAR(MAX),
		@error_message VARCHAR(MAX)
		
	BEGIN TRY
		DECLARE @now DATETIME = GETDATE()

		UPDATE cl
		SET Last_Updated_Date = @now
		FROM Magento.tgc_upsell_customer_list cl
		WHERE EXISTS (SELECT 1 FROM INSERTED i
						WHERE i.dax_customer_id = cl.dax_customer_id
							AND i.location_id = cl.location_id
							AND i.test_rank = cl.test_rank
					)
	END TRY

	BEGIN CATCH
	    SELECT
			@error_number = ERROR_NUMBER(),
			@error_severity = ERROR_SEVERITY(),
			@error_state = ERROR_STATE(),
			@sp_name = ISNULL(OBJECT_NAME(@@PROCID),''),
			@error_line = ERROR_LINE(),
			@error_message = ERROR_MESSAGE(),
			@user_name = SYSTEM_USER

		SELECT @error_description = CHAR(13) + '[' + @sp_name + '] has failed.' + CHAR(13)
			+ 'Error Number: ' + CONVERT(VARCHAR,@error_number) 
			+ ', Line: ' + CONVERT(VARCHAR,@error_line)
			+ ', User: "' + @user_name + '"'
			+ ', Error Message: "' + @error_message + '"'
		
		-- Close open transactions, only use if using transactions
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END

		RAISERROR(@error_description, @error_severity, @error_state)

	END CATCH

	SET NOCOUNT OFF
END
GO
ALTER TABLE [Magento].[tgc_upsell_customer_list] ADD CONSTRAINT [PK__tgc_upse__27288F0B41F6ACAC] PRIMARY KEY CLUSTERED  ([dax_customer_id], [location_id], [test_rank]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tgc_upsell_customer_list_last_update] ON [Magento].[tgc_upsell_customer_list] ([Last_Updated_Date]) ON [PRIMARY]
GO
ALTER TABLE [Magento].[tgc_upsell_customer_list] ADD CONSTRAINT [FK_Location_ID] FOREIGN KEY ([location_id]) REFERENCES [Magento].[tgc_upsell_location] ([location_id])
GO
