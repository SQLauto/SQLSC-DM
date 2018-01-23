SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[SP_Directory_FacebookAdCodes_DropFolder]
 @DropFolder varchar (255)= null output, 
 @ArchiveFolder varchar (255)= null output  
as  
Begin  
  
--Base Folder  
Set @DropFolder = '\\TTCDMFS01\ServerRepo\DatamartETL\Facebook Ad Test\DropFolder'

Set @ArchiveFolder = '\\TTCDMFS01\ServerRepo\DatamartETL\Facebook Ad Test\ArchiveFolder'  
  
 select @DropFolder,@ArchiveFolder  
End  
  
GO
