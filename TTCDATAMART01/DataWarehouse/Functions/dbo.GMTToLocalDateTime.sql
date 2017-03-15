SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[GMTToLocalDateTime] (@dt [datetime])
RETURNS [datetime]
WITH EXECUTE AS CALLER
EXTERNAL NAME [DataWarehouseCLR].[UserDefinedFunctions].[GMTToLocalDateTime]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'FUNCTION', N'GMTToLocalDateTime', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'GMTToLocalDateTime.cs', 'SCHEMA', N'dbo', 'FUNCTION', N'GMTToLocalDateTime', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=9
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'GMTToLocalDateTime', NULL, NULL
GO
