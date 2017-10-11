SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE function [dbo].[least] (@str1 nvarchar(max),@str2 nvarchar(max))
RETURNS nvarchar(max)
BEGIN

   DECLARE @retVal nvarchar(max);

   set @retVal = (select case when @str1<=@str2 then @str1 end as retVal)

   RETURN @retVal;
END;
GO
