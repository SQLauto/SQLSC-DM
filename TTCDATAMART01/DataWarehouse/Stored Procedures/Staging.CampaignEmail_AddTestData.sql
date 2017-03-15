SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[CampaignEmail_AddTestData]
	@TableName varchar(100),
    @DatabaseName varchar(20) = 'Ecampaigns'
AS
	declare 
    	@SQLStatement nvarchar(300)
BEGIN
    set nocount on
    
    exec Staging.CampaignEmail_DropTempTables
    
    set @SQLStatement = 'select * into Staging.TempECampaignEmailTemplate from ' + @DatabaseName + '..' + @TableName + ' (nolock)'    
    
	exec sp_executesql @SQLStatement

    ;with cteTestData(CustomerID, RowNum) as
    (
		select 
            max(t.CustomerID), 
			1
		from Staging.TempECampaignEmailTemplate t (nolock)
		where 
        	t.FlagAdcodeActive = 1 
            and isnull(t.PreferredCategory, '') <> ''
            and t.CustomerID > 0
		group by t.PreferredCategory, t.AdCode
		union
		select 
			max(t.CustomerID), 
		    row_number() over(partition by t.AdCode order by t.AdCode)
		from Staging.TempECampaignEmailTemplate t (nolock)
		where 
        	t.FlagAdcodeActive = 0 
            and isnull(t.PreferredCategory, '') <> ''
		group by t.PreferredCategory, t.AdCode
	)
    insert into Staging.TempECampaignEmailTemplate
    (
      	AdCode,
        CatalogName,
        ComboID,
        CustHTML,
        CustomerID,
        DeadlineDate,
        ECampaignID,
        EmailAddress,
        EmailStatus,
        FirstName,
        FlagAdcodeActive,
        LastName,
        PreferredCategory,
        Region,
        SendDate,
        SubjectLine,
        Unsubscribe
    )
    select 
    	et.AdCode,
        et.CatalogName,
        et.ComboID,
        et.CustHTML,
        '-' + et.CustomerID,
        et.DeadlineDate,
        et.ECampaignID,
        '~DLemailcampaigntest@teachco.com',
        et.EmailStatus,
        et.FirstName,
        et.FlagAdcodeActive,
        et.LastName,
        et.PreferredCategory,
        et.Region,
        et.SendDate,
        et.SubjectLine,
        et.Unsubscribe
    from Staging.TempECampaignEmailTemplate et (nolock)
    join cteTestData t on et.CustomerID = t.CustomerID
    where t.RowNum <= 3
    
    ;with cteTestData(CustomerID, RowNum) as
    (
		select
	        max(t.CustomerID),
		    -1 - row_number() over(order by t.AdCode)
		from Staging.TempECampaignEmailTemplate t (nolock)
        where t.FlagAdcodeActive = 0 and t.CustomerID > 0
		group by t.AdCode
	)        
    insert into Staging.TempECampaignEmailTemplate
    (
      	AdCode,
        CatalogName,
        ComboID,
        CustHTML,
        CustomerID,
        DeadlineDate,
        ECampaignID,
        EmailAddress,
        EmailStatus,
        FirstName,
        FlagAdcodeActive,
        LastName,
        PreferredCategory,
        Region,
        SendDate,
        SubjectLine,
        Unsubscribe
    )
    select 
    	et.AdCode,
        et.CatalogName,
        et.ComboID,
        et.CustHTML,
        RowNum,
        et.DeadlineDate,
        et.ECampaignID,
        '~DLemailcampaigntest@teachco.com',
        et.EmailStatus,
        'Testing',
        et.FlagAdcodeActive,
        et.AdCode,
        et.PreferredCategory,
        et.Region,
        et.SendDate,
        et.SubjectLine,
        et.Unsubscribe
    from Staging.TempECampaignEmailTemplate et (nolock)
    join cteTestData t on et.CustomerID = t.CustomerID
    
	delete et
    from Staging.TempECampaignEmailTemplate et
    where 
    	et.CustomerID > 0
        and et.CustomerID not in (select ec.CustomerID from Staging.vwEmailableCustomers ec (nolock))    
    
    set @SQLStatement = 'drop table ' + @DatabaseName + '..' + @TableName
	exec sp_executesql @SQLStatement
    set @SQLStatement = 'select * into '  + @DatabaseName + '..' + @TableName + ' from Staging.TempECampaignEmailTemplate (nolock)'
	exec sp_executesql @SQLStatement
    exec Staging.CampaignEmail_DropTempTables
    
END
GO
