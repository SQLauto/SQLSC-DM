SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE FUNCTION [Staging].[Proper] (@tcString VARCHAR(100))
	RETURNS VARCHAR(100) AS
BEGIN
	/* Scratch variables used for processing*/
	DECLARE @outputString VARCHAR(100)
	DECLARE @stringLength INT
	DECLARE @loopCounter INT
	DECLARE @charAtPos VARCHAR(1)
	DECLARE @wordStart INT

	/* If the incoming string is NULL, return an error*/
	IF (@tcString IS NULL)
		RETURN ('')

	/* Initialize the scratch variables*/
	SET @outputString = ''
	SET @stringLength = LEN (@tcString)
	SET @loopCounter = 1
	SET @wordStart = 1
	
	/* Loop over the string*/
	WHILE (@loopCounter <= @stringLength)
	BEGIN
		/* Get the single character off the string*/
		SET @charAtPos = SUBSTRING (@tcString, @loopCounter, 1)

		/* If we are the start of a word, uppercase the character*/
		/* and reset the work indicator*/
		IF (@wordStart = 1)
		BEGIN
			SET @charAtPos = UPPER (@charAtPos)
			SET @wordStart = 0
		END
		ELSE
		BEGIN
			SET @charAtPos = LOWER(@charAtPos)
		END

		/* If we encounter a white space, indicate that we*/
		/* are about to start a word*/
		IF (@charAtPos = ' ')
			SET @wordStart = 1

		/* Form the output string*/
		SET @outputString = @outputString + @charAtPos

		SET @loopCounter = @loopCounter + 1
	END

	/* Return the final output*/
	RETURN (@outputString)
END
GO
