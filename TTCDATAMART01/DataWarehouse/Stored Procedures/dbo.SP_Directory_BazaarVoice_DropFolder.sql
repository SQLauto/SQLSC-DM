SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[SP_Directory_BazaarVoice_DropFolder] @DropFolder varchar (255) output,@ArchiveFolder varchar (255) output
as
Begin

--Base Folder
Set @DropFolder = '\\File1\Groups\Marketing\BazaarVoice\DropFolder'
Set @ArchiveFolder = '\\File1\Groups\Marketing\BazaarVoice\Archive'

--select @DropFolder,@ArchiveFolder
End

GO
