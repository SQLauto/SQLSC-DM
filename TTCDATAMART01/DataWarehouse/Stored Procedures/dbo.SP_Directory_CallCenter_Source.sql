SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[SP_Directory_CallCenter_Source]
 @SourceFolder varchar (255)= null output,
 @Drop varchar (255) = null output
 as
Begin  
  
--Base Folder  
Set @SourceFolder  = '\\File1\groups\Marketing\Marketing Strategy and Analytics\CC Forecasting\SourceFolder'
Set @Drop = '\\TTCDMFS01\ServerRepo\DatamartETL\CC\DropFolder'

select @SourceFolder
select @Drop
end
GO
