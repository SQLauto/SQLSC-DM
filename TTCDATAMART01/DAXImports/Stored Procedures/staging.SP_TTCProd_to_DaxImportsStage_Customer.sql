SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: This routine is used to export customer information from DAX to Datamart.
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
--			04/27/2011	JonesT			Intial
--			04/29/2011	JonesT			Added temp tables and selection criteria.
--			05/20/2011	JonesT			Added Prefix/Suffix to customer export.
--			06/02/2011	JonesT			FOR TESTING HARD CODED START DATE TO 4/18/2011
--			07/16/2011	JonesT			Added customer Group (Library etc). Take only 1st 15 of Prefix/suffix
--			10/13/2011	JonesT			Added Company Name
--			10/28/2011	JonesT			Remove selection criteria since we are giving the full file each day.
--			06/22/2015	BryantJ			Refactor, reorganize, TRY/CATCH, NOLOCK, Transactions, renamed(was spExportCustomer), Added Blocked(Stopped) status to the Customer export
--			01/09/2017	BondugulaV		Converted to TTCProd Customer transfer to DaxImportsStage Process (P_Export_Customer_To_ExportTables)
------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [staging].[SP_TTCProd_to_DaxImportsStage_Customer]
AS
BEGIN

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
		BEGIN TRANSACTION
			TRUNCATE TABLE DaxImports.staging.CustomerExport

			INSERT INTO DaxImports.staging.CustomerExport
			SELECT Customerid = ACCOUNTNUM,
				InvoiceCustomerid = INVOICEACCOUNT,
				Fistname = JSFIRSTNAME,
				Middlename = JSMIDDLENAME,
				Lastname = JSLASTNAME,
				Customertype = JSCUSTTYPE,
				CustomerSince = CREATEDDATETIME,
				LastUpdated = MODIFIEDDATETIME,
				AddressmodifiedDate = JSADDRESSMODIFIED,
				JSORIGSOURCEID,
				JSMERGEDPARENT,
				JSMERGEDROOT,
				JSCUSTSTATUS,
				PHONE,
				CELLULARPHONE,
				EMAIL,
				Address1 = jsstreet1,
				Address2 = jsstreet2,
				Address3 = jsstreet3,
				city,
				[STATE],
				ZIPCODE,
				COUNTRYREGIONID,
				Prefix = LEFT(JSSALUTATION,15),
				Suffix = LEFT(JSNAMESUFFIX,15),
				CUSTGROUP,
				CASE BLOCKED	-- values here are taken from DAX
					WHEN 0 
						THEN 'No'
					WHEN 1
						THEN 'Invoice'
					WHEN 2
						THEN 'All'
					ELSE CONVERT(VARCHAR,BLOCKED)
				END AS Blocked
			FROM TTCPROD2009..custtable c WITH(NOLOCK)
		COMMIT TRANSACTION


		BEGIN TRANSACTION
			TRUNCATE TABLE DaxImports.staging.AddressExport 

			INSERT INTO DaxImports.staging.AddressExport 
 			SELECT c.ACCOUNTNUM, 
				dar.ISPRIMARY, 
				dar.[STATUS], 
				dar.JSDEFAULTDELIVERY,
				c.PARTYID,
				AddressName = addr.NAME,
				Prefix = ADDR.JSSALUTATION,
				ADDR.JSFIRSTNAME,
				ADDR.JSMIDDLENAME,
				ADDR.JSLASTNAME,
				ADDR.JSNAMESUFFIX,
				addr.jsSTREET1,
				addr.JSSTREET2,
				addr.JSSTREET3,
				addr.CITY,
				addr.[STATE],
				ADDR.ZIPCODE,
				addr.COUNTRYREGIONID,
				Plus4 = JSDLVZIPPLUSFOUR,
				MODIFIEDDATETIME = addr.MODIFIEDDATETIME,
				addr.JSCOMPANYNAME
			FROM  TTCPROD2009..custtable c WITH(NOLOCK)
				INNER JOIN TTCPROD2009..DirpartyAddressRelationship dar WITH(NOLOCK)
					ON c.PARTYID = dar.partyid
				INNER JOIN TTCPROD2009..DIRPARTYADDRESSRELATIONSHI1066 dar2 WITH(NOLOCK)
					ON dar.dataareaid = dar2.DATAAREAID
						AND dar.RECID = dar2.PARTYADDRESSRELATIONSHIPRECID
				INNER JOIN TTCPROD2009..[ADDRESS] addr WITH(NOLOCK)
					ON dar2.REFCOMPANYID = addr.DATAAREAID
						AND dar2.ADDRESSRECID = addr.recid
						AND addr.ADDRTABLEID IN (77,2303)
		COMMIT TRANSACTION


		BEGIN TRANSACTION
			TRUNCATE TABLE DaxImports.staging.CustomerOptinExport

			INSERT INTO DaxImports.staging.CustomerOptinExport 	
			SELECT j.CUSTACCOUNT, 
				j.Optinid
			FROM TTCPROD2009..JSCUSTOPTIN j WITH(NOLOCK)
			WHERE j.DATAAREAID = 'sco'
		COMMIT TRANSACTION

	End TRY

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

END

 




GO
