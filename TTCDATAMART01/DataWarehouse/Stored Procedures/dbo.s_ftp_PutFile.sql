SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[s_ftp_PutFile]
@FTPServer	varchar(128) ,
@FTPUser	varchar(128) ,
@FTPPWD		varchar(128) ,
@FTPPath	varchar(128) ,
@FTPFileName	varchar(128) ,

@SourcePath	varchar(128) ,
@SourceFile	varchar(128) ,

@workdir	varchar(128)
as
/*
exec s_ftp_PutFile 	
		@FTPServer = 'myftpsite' ,
		@FTPUser = 'username' ,
		@FTPPWD = 'password' ,
		@FTPPath = '/dir1/' ,
		@FTPFileName = 'test2.txt' ,
		@SourcePath = 'c:\vss\mywebsite\' ,
		@SourceFile = 'MyFileName.html' ,
		
		@workdir = 'c:\temp\'
		
		Parameter Data Type Description Example 
		@FTPServer varchar(128) The host name. ftp.example.com 
		@FTPUser nvarchar(128) The username for the FTP site. Haacked 
		@FTPPWD nvarchar(128) The password for the FTP site. Ha!_AsIfIWouldTellYou! 
		@FTPPath nvarchar(128) The subfolder within the FTP site to place the file. Make sure to use forward slashes and leave a trailing slash. / 
		@FTPFileName nvarchar(128) The filename to write within FTP. Typically the same as the source file name. ImportantFile.zip 
		@SourcePath nvarchar(128) The path to the directory that contains the source file. Make sure to have a trailing slash. c:\projects\ 
		@SourceFile nvarchar(128) The source file to ftp. ImportantFile.zip 
		@workdir nvarchar(128) The working directory. This is where the stored proc will temporarily write a command file containing the FTP commands it will execute. c:\temp\ 
		Here is an example of the usage. 

		exec FtpPutFile     
			@FTPServer = 'ftp.example.com' ,
			@FTPUser = n'username' ,
			@FTPPWD = n'password' ,
			@FTPPath = n'/dir1/' ,
			@FTPFileName = n'test2.txt' ,
			@SourcePath = n'c:\vss\mywebsite\' ,
			@SourceFile = n'MyFileName.html' ,
			@workdir = n'c:\temp\'
				
		
*/

declare	@cmd varchar(1000)
declare @workfilename varchar(128)
	
	select @workfilename = 'ftpcmd.txt'
	
	-- deal with special characters for echo commands
	select @FTPServer = replace(replace(replace(@FTPServer, '|', '^|'),'<','^<'),'>','^>')
	select @FTPUser = replace(replace(replace(@FTPUser, '|', '^|'),'<','^<'),'>','^>')
	select @FTPPWD = replace(replace(replace(@FTPPWD, '|', '^|'),'<','^<'),'>','^>')
	select @FTPPath = replace(replace(replace(@FTPPath, '|', '^|'),'<','^<'),'>','^>')
	
	select	@cmd = 'echo '					+ 'open ' + @FTPServer
			+ ' > ' + @workdir + @workfilename
	exec master..xp_cmdshell @cmd
	select	@cmd = 'echo '					+ @FTPUser
			+ '>> ' + @workdir + @workfilename
	exec master..xp_cmdshell @cmd
	select	@cmd = 'echo '					+ @FTPPWD
			+ '>> ' + @workdir + @workfilename
	exec master..xp_cmdshell @cmd
	select	@cmd = 'echo '					+ 'put ' + @SourcePath + @SourceFile + ' ' + @FTPPath + @FTPFileName
			+ ' >> ' + @workdir + @workfilename
	exec master..xp_cmdshell @cmd
	select	@cmd = 'echo '					+ 'quit'
			+ ' >> ' + @workdir + @workfilename
	exec master..xp_cmdshell @cmd
	
	select @cmd = 'ftp -s:' + @workdir + @workfilename
	
	create table #a (id int identity(1,1), s varchar(1000))
	insert #a
	exec master..xp_cmdshell @cmd
	
	select id, ouputtmp = s from #a
GO
