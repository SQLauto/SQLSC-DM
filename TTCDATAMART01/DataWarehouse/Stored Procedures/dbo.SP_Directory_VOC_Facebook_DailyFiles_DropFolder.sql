SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Directory_VOC_Facebook_DailyFiles_DropFolder] @DropFolder varchar (255)= null output,@ArchiveFolder varchar (255)= null output    
as    
Begin    
    
--Base Folder    
Set @DropFolder = '\\TTCDMFS01\ServerRepo\Reporting\R\VOC\Facebook'    
Set @ArchiveFolder = '\\TTCDMFS01\ServerRepo\Reporting\R\VOC\Facebook\Archive'    
    
 select @DropFolder,@ArchiveFolder    
End    
    
  
GO
