SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Staging].[CreateEmailSuppressionLists] 
	@CRDate varchar(8) = NULL,
	@DeBugCode INT = 1
AS

/* PR - 8/6/2015 - to create email suppression lists for prospect DLR emails.

-- Final table: rfm..CourseUpsellForAudible_YYYYMMDD

-- Generates Weekly Catalog Requet Mail files

*/

	DECLARE @SQLStatement nvarchar(300),
			@TablePrefix VARCHAR(100),
			@MailFilePath varchar(100)

	
	set @MailFilePath = '\\File1\Groups\Marketing\EmailSuppressionLists'

	IF @CRDate is null select @CRDate = CONVERT(varchar,GETDATE(),112)

	/* Create Child Account lists */
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'ChildEmails_TempFile')
        DROP TABLE Staging.ChildEmails_TempFile
        
	select a.Customerid, a.Firstname, a.Lastname, a.EMAIL, ISNULL(b.FlagEmail,0) as EmailPref,
			a.JSMERGEDROOT, a.CustomerSince
	into Staging.ChildEmails_TempFile
	from DAXImports..CustomerExport a 
		left join (select distinct customerid, 1 as FlagEmail
				from DAXImports..CustomerOptinExport
				where Optinid = 'OfferEmail') b on a.Customerid = b.customerid			
	where isnull(JSMERGEDROOT,'') <> ''    
	
    /* Get all Non Emailable customers */
	
    IF @DeBugCode = 1 PRINT 'Create Non Emailable Temp table'
    
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'NonEmailable_TempFile')
        DROP TABLE Staging.NonEmailable_TempFile

	select distinct EmailAddress
	into Staging.NonEmailable_TempFile
	from DataWarehouse.Marketing.CampaignCustomerSignature
	where FlagEmail = 0
	
	-- include non emailable prospect
	insert into Staging.NonEmailable_TempFile
	select distinct EMAILADDRESS
	from DAXImports..TTCPROSPECTS
	where optinstatus = 1
	
	-- Also pull non emailable child accounts
	insert into Staging.NonEmailable_TempFile
	select distinct EMAIL
	from Staging.ChildEmails_TempFile
	where EmailPref = 0
	and email like '%@%'


    /* Get all Non Emailable customers */
	
    IF @DeBugCode = 1 PRINT 'Create Non Emailable Temp table'
    
    IF EXISTS (SELECT 8 FROM sysobjects WHERE Name = 'Emailable_TempFile')
        DROP TABLE Staging.Emailable_TempFile

	select distinct EmailAddress
	into Staging.Emailable_TempFile
	from DataWarehouse.Marketing.CampaignCustomerSignature
	where FlagEmail = 1
	
	-- include non emailable prospect
	insert into Staging.Emailable_TempFile
	select distinct EMAILADDRESS
	from DAXImports..TTCPROSPECTS
	where optinstatus <> 1
	
	-- Also pull non emailable child accounts
	insert into Staging.Emailable_TempFile
	select distinct EMAIL
	from Staging.ChildEmails_TempFile
	where EmailPref = 1
	and email like '%@%'
	

	-- Create final files For 'DO NOT Email' Folks
    IF @DeBugCode = 1 PRINT 'Create final files'
	declare @EmailSupTableFnlDNE varchar(100),
			@EmailSupFileFnlDNE varchar(100)	
		
	select @EmailSupTableFnlDNE = 'rfm.dbo.TTC_EmailSpprssn_DoNotEmail_' + @CRDate
	select @EmailSupFileFnlDNE = 'TTC_EmailSpprssn_DoNotEmail_' + @CRDate 
	
	IF EXISTS(SELECT 1 FROM rfm.sys.tables WHERE name = replace(@EmailSupTableFnlDNE,'rfm.dbo.',''))
		begin
			set @SQLStatement = 'Drop table ' + @EmailSupTableFnlDNE
			print @SQLStatement
			exec (@SQLStatement)				
		end
		   
	set @SQLStatement = 'select *
				into ' + @EmailSupTableFnlDNE + 
				' from Staging.NonEmailable_TempFile'
			
	print @SQLStatement
	exec (@SQLStatement)
			
	set @SQLStatement = 'select count(*) from ' + @EmailSupTableFnlDNE 
			
	print @SQLStatement
	exec (@SQLStatement)
				
    IF @DeBugCode = 1 PRINT 'Export file to appropriate folder'		
	exec staging.ExportTableToPipeText rfm, dbo, @EmailSupFileFnlDNE, @MailFilePath

	-- Create final files for Emailable folks
    IF @DeBugCode = 1 PRINT 'Create final files'
	declare @EmailSupTableFnlEM varchar(100),
			@EmailSupFileFnlEM varchar(100)	
		
	select @EmailSupTableFnlEM = 'rfm.dbo.TTC_EmailSpprssn_Emailable_' + @CRDate
	select @EmailSupFileFnlEM = 'TTC_EmailSpprssn_Emailable_' + @CRDate 
	
	IF EXISTS(SELECT 1 FROM rfm.sys.tables WHERE name = replace(@EmailSupTableFnlEM,'rfm.dbo.',''))
		begin
			set @SQLStatement = 'Drop table ' + @EmailSupTableFnlEM
			print @SQLStatement
			exec (@SQLStatement)				
		end
		   
	set @SQLStatement = 'select *
				into ' + @EmailSupTableFnlEM + 
				' from Staging.Emailable_TempFile'
			
	print @SQLStatement
	exec (@SQLStatement)		
		
    IF @DeBugCode = 1 PRINT 'Export file to appropriate folder'		
	exec staging.ExportTableToPipeText rfm, dbo, @EmailSupFileFnlEM, @MailFilePath
	
	---- QC
	--declare @QCTbl varchar(100)
	
	--set @QCTbl = 'TTC_EmailSpp%' + @CRDate


	--set @SQLStatement = 'SELECT 
	--	[TableName] = so.name + ''FNL.txt'', 
	--	[RowCount] = MAX(si.rows),
	--	so.crdate 
	--FROM rfm.sys.sysobjects so, 
	--	rfm.sys.sysindexes si 
	--WHERE so.xtype = ''U'' 
	--	AND si.id = OBJECT_ID(so.name) 
	--	and so.name like ''' + @QCTbl + '''	GROUP BY so.name, so.crdate'
			
	--print @SQLStatement
	--exec (@SQLStatement)	
	
		
    DROP TABLE Staging.NonEmailable_TempFile
	DROP TABLE Staging.ChildEmails_TempFile
	drop table Staging.Emailable_TempFile
	
GO
