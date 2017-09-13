SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[Wordparser]
(
  @multiwordstring VARCHAR(255),
  @wordnumber      NUMERIC,
  @delimiter varchar(1) = ','
)
returns VARCHAR(255)
AS
  BEGIN
      DECLARE @remainingstring VARCHAR(255)
      SET @remainingstring=@multiwordstring

      DECLARE @numberofwords NUMERIC
      SET @numberofwords=(LEN(@remainingstring) - LEN(REPLACE(@remainingstring, @delimiter, '')) + 1)

      DECLARE @word VARCHAR(50)
      DECLARE @parsedwords TABLE
      (
         line NUMERIC IDENTITY(1, 1),
         word VARCHAR(255)
      )

      WHILE @numberofwords > 1
        BEGIN
            SET @word=LEFT(@remainingstring, CHARINDEX(@delimiter, @remainingstring) - 1)

            INSERT INTO @parsedwords(word)
            SELECT @word

            SET @remainingstring= REPLACE(@remainingstring, Concat(@word, @delimiter), '')
            SET @numberofwords=(LEN(@remainingstring) - LEN(REPLACE(@remainingstring, @delimiter, '')) + 1)

            IF @numberofwords = 1
              BREAK

            ELSE
              CONTINUE
        END

      IF @numberofwords = 1
        SELECT @word = @remainingstring
      INSERT INTO @parsedwords(word)
      SELECT @word

      RETURN
        (SELECT word
         FROM   @parsedwords
         WHERE  line = @wordnumber)

  END
GO
