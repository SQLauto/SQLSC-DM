SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Procedure [dbo].[SP_Directory_TGCAffiliate_MonthlyFiles_DropFolder]
 @DropFolder varchar (255)= null output, 
 @ArchiveFolder varchar (255)= null output  
as  
Begin  
  
--Base Folder  
Set @DropFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\ECommerce\Affiliate\DropFolder'

Set @ArchiveFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\ECommerce\Affiliate\Archive'  
  
 select @DropFolder,@ArchiveFolder  
End  
  
GO
