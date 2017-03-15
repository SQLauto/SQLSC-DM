SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create FUNCTION [Staging].[RemoveDigits]
(
	@string varchar(100)
)
RETURNS varchar(100)
AS
BEGIN
	while patindex( '%[^a-z]%', @string ) > 0 
	set @string = replace(@string, substring(@string, patindex('%[^a-z]%', @string), 1), '') 
	return @string            
END
GO
