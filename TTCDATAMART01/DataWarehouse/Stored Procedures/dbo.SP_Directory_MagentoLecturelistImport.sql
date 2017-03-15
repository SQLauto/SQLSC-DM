SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE proc [dbo].[SP_Directory_MagentoLecturelistImport] @source varchar(1000)=null output,@dest varchar(1000)=null output  
as      
      
begin      
      
Set @source = '\\ttcdmfs01\serverrepo\DatamartETL\MagentoLectureList\DropFolder'      
/*Keep in same folder*/      
set @dest =   '\\ttcdmfs01\serverrepo\DatamartETL\MagentoLectureList\Archived'    
select    @source as '@source'   ,@dest as '@dest'
      
End 
GO
