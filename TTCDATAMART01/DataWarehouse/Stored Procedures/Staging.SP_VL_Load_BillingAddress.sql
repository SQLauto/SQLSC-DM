SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [Staging].[SP_VL_Load_BillingAddress]  
as  
begin  



/*Update Previous Counts*/
exec SP_TGCPlus_UpdatePreviousCounts @TGCPlusTableName = 'TGCPlus_BillingAddress'

/*truncate table [Archive].TGCPlus_BillingAddress  */


Delete A from [Archive].TGCPlus_BillingAddress A
join Staging.VL_ssis_BillingAddress S
on S.userId = A.userId


insert into  [Archive].TGCPlus_BillingAddress  
([userId] ,[userEmail],[userFirstName] ,[userLastName] ,[line1],[line2] ,[line3],[county],[city] ,[region] ,[postalCode] ,[country],[Fullname])  
select Distinct [userId]  
,[userEmail]  
,[userFirstName]   
,[userLastName]   
,[line1]  
,[line2]   
,[line3]  
,[county]  
,[city]   
,[region]   
,[postalCode]   
,[country]   
,[Fullname]
from Staging.VL_ssis_BillingAddress  
where Useremail not like '%+%'
and Useremail not like '%plustest%'
/* Added filter to remove + and plustest address data*/


	/* Remove any carriage returns in the address field*/
    UPDATE [Archive].TGCPlus_BillingAddress
       SET line1 = replace(replace(ISNULL(line1,''),char(13),''),char(10),''),
            line2 = replace(replace(ISNULL(line2,''),char(13),''),char(10),''),
            line3 = replace(replace(ISNULL(line3,''),char(13),''),char(10),''),            
            [userFirstName] = replace(replace(ISNULL([userFirstName],''),char(13),''),char(10),''),
            [userLastName] = replace(replace(ISNULL([userLastName],''),char(13),''),char(10),'')
            
    /* Replace commas with spaces*/
    UPDATE [Archive].TGCPlus_BillingAddress
       SET line1 = replace(line1,',',' '),
            line2 = replace(line2,',',' '),
            line3 = replace(line3,',',' '),
            [userFirstName] = replace([userFirstName],',',' '),
            [userLastName] = replace([userLastName],',',' ')
            
    /* Replace pipes with dashes*/
    -- PR 1/19/2013 - to avoid issues with mail files which are sent to vendors
    -- as pipe separated text files.
    UPDATE [Archive].TGCPlus_BillingAddress
       SET line1 = replace(line1,'|','-'),
            line2 = replace(line2,'|','-'),
            line3 = replace(line3,'|','-'),
            [userFirstName] = replace([userFirstName],'|','-'),
            [userLastName] = replace([userLastName],'|','-') 

/* Replace speacial character '	' and replacing with blanks ''*/ 
--Julia needed this update for reports

    UPDATE [Archive].TGCPlus_BillingAddress
	set 
	[userFirstName] = replace([userFirstName],'	',''),
	[userLastName] = replace([userLastName],'	',''),
	line1 = replace(line1,'	',''),
	line2 = replace(line2,'	',''),
	line3 = replace(line3,'	',''),
	city = replace(city,'	',''),
	county = replace(county,'	',''),
	region = replace(region,'	',''),
	postalCode = replace(postalCode,'	',''),
	country= replace(country,'	','')

/*Update Counts*/
exec SP_TGCPlus_UpdateCurrentCounts @TGCPlusTableName = 'TGCPlus_BillingAddress'
  

     If exists (select top 1 * from Datawarehouse.staging.vl_ssis_userbilling_Errors where cast(DMlastupdated as date) = cast(getdate() as date))

   Begin
   

		declare @ErrorRowCounts varchar(1000) 
   
		select @ErrorRowCounts = isnull(Count(*),0) from Datawarehouse.staging.vl_ssis_userbilling_Errors where cast(DMlastupdated as date) = cast(getdate() as date)


		set @ErrorRowCounts = '@ErrorRowCounts Due to Truncation Error is <b> ' + @ErrorRowCounts + ' </b>  .
   		' +	'  Check the below table <b> select * from DataWarehouse.staging.vl_ssis_userbilling_Errors where cast(DMlastupdated as date) = cast(getdate() as date)</b>'

   select     @ErrorRowCounts  


		DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(max)
		DECLARE @p_recipients as nvarchar(max), @p_profile_name as nvarchar(max)
		SET @p_profile_name = N'DL datamart alerts'
		SET @p_recipients = N'DLDatamartAlerts@TEACHCO.com'
		SET @p_subject = N'Data Added today to Datawarehouse.staging.vl_ssis_userbilling_Errors'
		SET @p_body = @ErrorRowCounts
		EXEC msdb.dbo.sp_send_dbmail
		  @profile_name = @p_profile_name,
		  @recipients = @p_recipients,
		  @body = @p_body,
		  @body_format = 'HTML',
		  @subject = @p_subject
	end





End





GO
