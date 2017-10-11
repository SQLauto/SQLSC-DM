SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[greatest] (@str1 nvarchar(max),@str2 nvarchar(max))
RETURNS nvarchar(max)
BEGIN

   DECLARE @retVal nvarchar(max);

   set @retVal = (select case when @str1<=@str2 then @str2 end as retVal)

   RETURN @retVal;
END;
GO
