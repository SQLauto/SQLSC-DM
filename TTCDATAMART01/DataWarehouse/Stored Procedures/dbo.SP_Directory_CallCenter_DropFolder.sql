SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[SP_Directory_CallCenter_DropFolder]
 @DropFolder varchar (255)= null output,
 @ArchiveFolder varchar (255) = null output,
 @Archive varchar(255) = null output
 as
Begin  
  
--Base Folder  
Set @DropFolder = '\\TTCDMFS01\ServerRepo\DatamartETL\CC\DropFolder'
Set @ArchiveFolder = '\\TTCDMFS01\ServerRepo\DatamartETL\CC\ArchiveFolder'
set @Archive = '\\File1\groups\Marketing\Marketing Strategy and Analytics\CC Forecasting\Archive'
  
 select @DropFolder
 select @ArchiveFolder
 select @Archive
End  
GO
