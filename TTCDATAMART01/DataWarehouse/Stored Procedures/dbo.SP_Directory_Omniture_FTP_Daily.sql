SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Directory_Omniture_FTP_Daily] 
 @FTPServername varchar(200)= null output
,@FTPUsername varchar(200)= null output
,@FTPPassword varchar(200)= null output
,@FTPPath varchar(200)= null output
,@Localpath varchar(200)= null output
,@Unzip varchar(200)= null output
as

begin

set @FTPServername = 'ftp.omniture.com'

set @FTPUsername = 'teachingcodev_9573940'

set @FTPPassword = 'i4F09Wwv'

set @FTPPath = '/OmnitureDailyExport/*.zip'

set @Localpath = '\\TTCDMFS01\ServerRepo\DatamartETL\Omniture\OmnitureDailyImport'

--UnZiped Folder
set @Unzip = '\\TTCDMFS01\ServerRepo\DatamartETL\Omniture\DailyFiles'

select @FTPServername as '@FTPServername',@FTPUsername as '@FTPUsername' , @FTPPassword as '@FTPPassword', @FTPPath as '@FTPPath'
 ,@Localpath as '@Localpath', @Unzip as '@Unzip'
end

GO
