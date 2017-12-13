SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE Proc [dbo].[SP_Directory_Omniture_DailyFiles_DropFolder] @DropFolder varchar (255)= null output,@ArchiveFolder varchar (255)= null output  
as  
Begin  
  
--Base Folder  
Set @DropFolder = '\\TTCDMFS01\ServerRepo\DatamartETL\Omniture\DailyFiles'  
Set @ArchiveFolder = '\\TTCDMFS01\ServerRepo\DatamartETL\Omniture\Archive\DailyFiles'  
  
 select @DropFolder,@ArchiveFolder  
End  
  

GO
