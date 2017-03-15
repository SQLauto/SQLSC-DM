SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[SP_EmailHistory_Date] @date as nvarchar(8) = null output
as 
begin

select @date = cast (convert(varchar(8), getdate()-1, 112)  as nvarchar(8))


select @date as '@date'

End
GO
