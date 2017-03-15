SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_Directory_CustomerOverlay_MonthlyFolder_WD] @CurrentMonthFolder varchar (255)= null output,@DropFolder varchar (255)= null output
as
Begin

Declare @year varchar (10),@month varchar(3)
select @year = cast(datepart(yyyy,GETDATE()) as varchar(4)),@month = cast(GETDATE() as varchar(3))


--Base Folder
Set @CurrentMonthFolder = '\\File1\Groups\Marketing\WebDecisions\HouseFileInformationToWD\FromWD\'+ @year + '\'+ @month +'_FilesFromWD'

Set @DropFolder = '\\File1\Groups\Marketing\WebDecisions\HouseFileInformationToWD\FromWD\DropFolder'

select @DropFolder as '@DropFolder',@CurrentMonthFolder as '@CurrentMonthFolder'


End
GO
