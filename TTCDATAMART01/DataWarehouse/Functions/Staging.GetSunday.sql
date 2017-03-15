SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE  FUNCTION [Staging].[GetSunday] (@date DATETIME)
	RETURNS VARCHAR(100) AS
BEGIN

/* Preethi Ramanujam 	12/10/2007	To get Sunday date given any date*/

DECLARE @d DATETIME,
	@OutPutDate varchar(30)

SET @d = CONVERT(DATETIME, CONVERT(VARCHAR(10),  @date, 101))

SELECT @OutPutDate = CONVERT(VARCHAR,DATEADD(dd, 1 - DATEPART(dw, @d), @d),101)

	/* Return the final output*/
	RETURN (@OutPutDate)
END
GO
