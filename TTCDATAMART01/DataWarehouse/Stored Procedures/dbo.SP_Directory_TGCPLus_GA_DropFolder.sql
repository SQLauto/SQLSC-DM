SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create Proc [dbo].[SP_Directory_TGCPLus_GA_DropFolder] @DropFolder varchar (255) output,@ArchiveFolder varchar (255) output
as
Begin

--Base Folder
Set @DropFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\GoogleAnalytics\DropFolder'
Set @ArchiveFolder = '\\File1\Groups\Marketing\Marketing Strategy and Analytics\Subscription\GoogleAnalytics\ArchiveFolder'

select @DropFolder,@ArchiveFolder
End


GO
