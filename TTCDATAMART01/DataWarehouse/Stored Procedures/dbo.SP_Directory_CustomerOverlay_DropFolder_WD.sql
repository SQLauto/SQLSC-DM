SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Directory_CustomerOverlay_DropFolder_WD] @DropFolder varchar (255) output
as
Begin

--Base Folder
Set @DropFolder = '\\File1\Groups\Marketing\WebDecisions\HouseFileInformationToWD\FromWD\DropFolder'

--select @DropFolder

End
GO
