SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------
-- Description: This turns the system built in SP into an inline function
------------------------------------------------------------------------------------------------------------------------------------------
-- Issue#	Date		Modified By		Details
------------------------------------------------------------------------------------------------------------------------------------------
-- US2269	07/20/2016	BryantJ			Initial
------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[F_File_Exists]
	(@Full_Path VARCHAR(4000)
	)
RETURNS INT
AS
BEGIN
	DECLARE @is_exists INT

	EXEC master.dbo.xp_fileexist 
		@Full_Path, 
		@is_exists OUTPUT

	RETURN @is_exists
END
GO
