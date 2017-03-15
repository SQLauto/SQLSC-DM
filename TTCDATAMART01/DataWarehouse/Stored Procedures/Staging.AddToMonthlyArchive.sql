SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [Staging].[AddToMonthlyArchive]
	@TableName varchar(100)
as 
	declare 
   	@SQLStatement nvarchar(500),
    @ArchiveTableName varchar(100)
begin
    set nocount on
	
    set @ArchiveTableName = 'Archive.' + @TableName + convert(varchar(8), getdate(), 112)
    
    if object_id(@ArchiveTableName) is not null
    begin
        set @SQLStatement = 'drop table ' + @ArchiveTableName
		exec sp_executesql @SQLStatement
    end            
    	
    set @SQLStatement = 'select * into ' + @ArchiveTableName + ' from Staging.Temp' + @TableName + ' (nolock)'
	exec sp_executesql @SQLStatement
    set @SQLStatement = 
    	'create clustered index pk' + replace(@ArchiveTableName, 'Archive.', '') + 
	    'CustomerID on ' + @ArchiveTableName + '(CustomerID) on ARCHIVE'
	exec sp_executesql @SQLStatement
end
GO
