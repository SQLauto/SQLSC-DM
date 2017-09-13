SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_FB_TGC_FilesByCourse]
	@CourseID INT,
	@FormatType varchar(20) = 'Digital only',
	@CountryCode varchar(3) = 'All'
as
Begin


Declare @SQL Nvarchar(2000)
	,@Date varchar(8)
	,@Dest Nvarchar(200)
	,@FnlTable Nvarchar(200)
	,@Year varchar(4)
	,@FormatSql nvarchar(2000)
	,@CountrySql nvarchar(2000)
	,@ErrorMsg varchar(2000)


    /*- Check to make sure CatalogCode is provided by the user.*/
    IF @CourseID IS NULL
    BEGIN	
        SET @ErrorMsg = 'Please provide a courseID'
        RAISERROR(@ErrorMsg,15,1)
        RETURN
    END

	declare @QCCourse int
	select @QCCourse = count(*) 
	from Mapping.DMCourse
	where courseid = @CourseID
	and BundleFlag = 0
	select @QCCourse

    IF @CourseID = 0
    BEGIN	
        SET @ErrorMsg = 'Please provide a valid courseID'
        RAISERROR(@ErrorMsg,15,1)
        RETURN
    END

/* TGCPlus Emails list for Facebook FB */


set @Date = convert(varchar, getdate(),112)

set  @Year = year(@Date)


/* TableName */

set @FnlTable = 'FB_TGC_File_' + convert(varchar,@CourseID) + '_' + replace(@FormatType,' ','') + '_' + @CountryCode + '_' + @Date
print '@FnlTable = ' + @FnlTable

/* Folder Name */
declare @FolderName varchar(200)

set @FolderName = 'FB_TGC_File_CourseCountry'--' + convert(varchar,@CourseID) + '_' + @CountryCode + '_' + @Date
print '@FolderName = ' + @FolderName

/* Create Directoty */
set @Dest = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\FaceBook\FaceBookCampaigns\' + @FolderName + '_' + @Date
EXEC master.dbo.xp_create_subdir @Dest
------------------------------------------------------------------------------------------------------------------------------

 /*Get base query*/


 select @FormatSql = case when @FormatType = 'Digital Only' then ' and a.FormatMedia in (''DV'',''DL'')'
						else ' '
					 end
print '@FormatSql = ' + @FormatSql

 select @CountrySql = case when @CountryCode = 'All' then ' '
						when @countryCode in ('US','AU','GB','CA') then ' and c.countrycode in (''' + @CountryCode + ''')'
						else ' '
					 end
print '@CountrySql = ' + @CountrySql

  if object_id('RFM.dbo.' + @FnlTable) is not null 
    begin
		set @SQL = 'drop table RFM.dbo.' + @FnlTable
		exec sp_executesql @SQL
    end


set @SQL =	'select distinct a.CourseID
			,replace(b.Email,''|'','''') EmailAddress
			,replace(c.FirstName,''|'','''') FirstName
			,replace(c.LastName,''|'','''') LastName
			,replace(c.State,''|'','''') State
			,replace(c.City,''|'','''') City
			,c.PostalCode as ZipCode
			,c.CountryCode
		into rfm..' + @FnlTable + char(10) +-- char(13) +
		' from DataWarehouse.marketing.DMPurchaseOrderItems a left join
			DataWarehouse.marketing.epc_preference b on a.CustomerID = b.CustomerID left join
			DataWarehouse.Marketing.CampaignCustomerSignature c on a.customerid = c.customerid
		where a.courseid in (' + convert(varchar,@CourseID) + ')'
		+ @CountrySql
		+ @FormatSql
		

Print @SQL
Exec  (@SQL)
----set @File = 'FB_TGC_Active_Multi_Emailable_' + @Date

--/*Export @File to @Dest*/
exec staging.ExportTableToPipeText rfm, dbo, @FnlTable, @Dest






--DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(max)
--DECLARE @p_recipients as nvarchar(max), @p_profile_name as nvarchar(max)
--SET @p_profile_name = N'DL datamart alerts'
--SET @p_recipients = N'~dldatamartalerts@TEACHCO.com'
--SET @p_subject = N'FaceBook TGC Weekly Report'
--SET @p_body = '<b>Facebook TGC Weekly Report has been created</b>.  let others know that the report is ready here ' + @Dest
--EXEC msdb.dbo.sp_send_dbmail
--  @profile_name = @p_profile_name,
--  @recipients = @p_recipients,
--  @body = @p_body,
--  @body_format = 'HTML',
--  @subject = @p_subject

End 


GO
