SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [Staging].[ExportTableToPipeText]
	@DbName varchar(25),
	@SchemaName varchar(20),
	@TableName varchar(100),
	@Path varchar(200),
	@FnlFile varchar(100) = null

AS

-- To export table to pipe delimited files
-- Preethi Ramanujam 1/16/2014


	declare @Text varchar(100),
		@Header varchar(100),
		@sql varchar(8000),
		@Temp varchar(100)

	select @Text = @TableName + '.txt',
		@Header = @TableName + 'Header.txt'
	 
	SELECT @sql = 'bcp "select * from ' + @DbName + '.' + @SchemaName + '.' + @TableName + '" queryout "' + @Path + '\' + @Text + '" -c -t'+'"|"'+' -T -S ttcdatamart01'
	 print @sql
	exec master..xp_cmdshell @sql

	 
	SELECT @sql = 'BCP "DECLARE @colnames VARCHAR(max);SELECT @colnames = COALESCE(@colnames + ''|'', '''') + column_name from ' + @DBName + '.INFORMATION_SCHEMA.COLUMNS where TABLE_NAME=''' + @TableName + ''' order by ORDINAL_POSITION; ; select @colnames;" queryout "' + @Path + '\' + @Header + '"   -c -t'+'"|"'+' -T -S ttcdatamart01'
	 print @sql
	exec master..xp_cmdshell @sql

	set @temp = @TableName + 'FNL.txt'
	select @FnlFile = COALESCE(@FnlFile, @temp)
	print @FnlFile

	SELECT @sql = 'copy /b "' + @Path +'\' + @Header + '" + "' + @Path + '\' + @Text + '" "' + @Path + '\' + @FnlFile + '"'
	 print @sql
	exec master..xp_cmdshell @sql


	SELECT @sql = 'del "' + @Path +'\' + @Header  + '"'
	 print @sql
	exec master..xp_cmdshell @sql


	SELECT @sql = 'del "' + @Path +'\' + @Text  + '"'
	 print @sql
	exec master..xp_cmdshell @sql





GO
