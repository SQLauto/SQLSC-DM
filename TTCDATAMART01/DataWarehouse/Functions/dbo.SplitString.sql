SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[SplitString]
(
    @List NVARCHAR(MAX),
    @Delim CHAR(1)
)
RETURNS TABLE
AS
    RETURN ( SELECT 
        rn, 
        vn = ROW_NUMBER() OVER (PARTITION BY [Value] ORDER BY rn), 
        [Value]
      FROM 
      ( 
        SELECT 
          rn = ROW_NUMBER() OVER (ORDER BY CHARINDEX(@Delim, @List + @Delim)),
          [Value] = LTRIM(RTRIM(SUBSTRING(@List, [Number],
          CHARINDEX(@Delim, @List + @Delim, [Number]) - [Number])))
        FROM dbo.Numbers
        WHERE Number <= LEN(@List)
        AND SUBSTRING(@Delim + @List, [Number], 1) = @Delim
      ) AS x
    );
GO
