SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[FN_REMOVEL_VOWELS] (@STRING VARCHAR(max), @StartPos int = 1)
returns varchar(max)
as 
begin

Declare @NewString varchar(max), @Len int, @StartString varchar(max), @FnlString varchar(max)


select @Len = len(@STRING) - @StartPos
select @NewString = SUBSTRING(@STRING,@StartPos,@Len)

select @StartString = case when @StartPos > 1 then SUBSTRING(@STRING,1,@StartPos)
						else ''
						end


select @NewString = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@NewString, 'A', ''), 'E', ''), 'O', ''), 'U', ''), 'I', '')

select @FnlString = @StartString + @NewString



RETURN @FnlString
END
GO
