SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Directory_TGCPlus_BillingAddress_DropFolder] @DropFolder varchar (255) output,@ArchiveFolder varchar (255) output  
as  
Begin  
  
--Base Folder  
Set @DropFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\SnagFilms\DropFolder\billing-address'  
Set @ArchiveFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\SnagFilms\DropFolder\Archive'  
  
--select @DropFolder,@ArchiveFolder  
End  
GO
