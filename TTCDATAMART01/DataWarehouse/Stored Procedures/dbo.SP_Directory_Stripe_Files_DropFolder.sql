SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Directory_Stripe_Files_DropFolder] @DropFolder varchar (255)= null output,@ArchiveFolder varchar (255)= null output    
as    
Begin    
    
--Base Folder    
Set @DropFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\SnagFilms\Stripe\Dropfolder'    
Set @ArchiveFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\SnagFilms\Stripe\Archive'    
    
 select @DropFolder,@ArchiveFolder    
End    
    
  
GO
