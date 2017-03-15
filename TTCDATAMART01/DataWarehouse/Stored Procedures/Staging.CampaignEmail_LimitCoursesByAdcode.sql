SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[CampaignEmail_LimitCoursesByAdcode]
	@TableName varchar(100),
    @AdCode int,
    @MaxCoursesNum int,
    @DatabaseName varchar(20) = 'Ecampaigns'
AS
	declare 
    	@SQLStatement nvarchar(300)
BEGIN
    set nocount on
    
    exec Staging.CampaignEmail_DropTempTables
    
    set @SQLStatement = 'select * into Staging.TempECampaignEmailTemplate from ' + @DatabaseName + '..' + 
    	@TableName + ' (nolock)'
	exec sp_executesql @SQLStatement
    
    set @SQLStatement = 'select * into Staging.TempECampaignCustomerCourseRank from ' + @DatabaseName + '..' + 
    	replace(@TableName, 'EmailTemplate', 'CustomerCourseRank') + ' (nolock)'    
	exec sp_executesql @SQLStatement
    
    delete ccr
    from Staging.TempECampaignCustomerCourseRank ccr
    join Staging.TempECampaignEmailTemplate et (nolock) on et.CustomerID = ccr.CustomerID
    where 
    	et.AdCode <> @AdCode
        or (et.AdCode = @AdCode and ccr.FinalRank > @MaxCoursesNum)
        
    ;with cteHTML(CustomerID, CustHTML) as
    (
        select 
            t.CustomerID,
            ( 
                select 
                    '##HDL' + cast(t2.CourseID as varchar(4)) + '## '
                from Staging.TempECampaignCustomerCourseRank t2 (nolock)
                where t2.CustomerID = t.CustomerID
                order by t2.FinalRank
                for xml path('') 
            )
            from Staging.TempECampaignCustomerCourseRank t (nolock)
            group by t.CustomerID
    )
	update et
    set et.CustHTML = cte.CustHTML
    from Staging.TempECampaignEmailTemplate et
    join cteHTML cte on cte.CustomerID = et.CustomerID 
            
    set @SQLStatement = 'drop table ' + @DatabaseName + '..' + @TableName
	exec sp_executesql @SQLStatement
    set @SQLStatement = 'select * into '  + @DatabaseName + '..' + @TableName + ' from Staging.TempECampaignEmailTemplate (nolock)'
	exec sp_executesql @SQLStatement
    exec Staging.CampaignEmail_DropTempTables
    
END
GO
