SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Staging].[IsDigit] (@string VARCHAR(8000))
/*
-- =================================================
-- IsDigit string Function
-- =================================================
-- Returns Non-Zero if all characters in @string are
--  digit (numeric) characters, 0 otherwise.

Select dbo.isdigit('how many times must I tell you')
Select dbo.isdigit('294856')
Select dbo.isdigit('569.45')
*/
RETURNS INT
AS BEGIN
      RETURN CASE WHEN PATINDEX('%[^0-9]%', @string) > 0 THEN 0
                  ELSE 1
             END
   END
GO
