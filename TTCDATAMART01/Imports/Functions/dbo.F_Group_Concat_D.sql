SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE AGGREGATE [dbo].[F_Group_Concat_D] (@VALUE [nvarchar] (4000), @DELIMITER [nvarchar] (4))
RETURNS [nvarchar] (max)
EXTERNAL NAME [GroupConcat].[GroupConcat.GROUP_CONCAT_D]
GO
