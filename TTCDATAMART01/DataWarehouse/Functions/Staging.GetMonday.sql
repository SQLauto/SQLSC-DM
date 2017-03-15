SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create   FUNCTION [Staging].[GetMonday] (@date DATETIME)
	RETURNS VARCHAR(100) AS
BEGIN

-- Preethi Ramanujam 	12/10/2007	To get Monday date given any date

DECLARE @d DATETIME,
	@OutPutDate varchar(30)

SET @d = CONVERT(DATETIME, CONVERT(VARCHAR(10),  @date, 101))

SELECT @OutPutDate = CONVERT(VARCHAR,DATEADD(dd, 2 - DATEPART(dw, @d), @d),101)

	-- Return the final output
	RETURN (@OutPutDate)
END
GO
