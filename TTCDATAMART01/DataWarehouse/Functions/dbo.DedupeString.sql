SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[DedupeString]
(
    @List NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN ( SELECT newval = STUFF((
     SELECT '\' + x.[Value] 
     FROM dbo.SplitString(@List, '\') AS x
      WHERE (x.vn = 1)
      ORDER BY x.rn
      FOR XML PATH, TYPE).value('.', 'nvarchar(max)'), 1, 1, '')
    );
END
GO
