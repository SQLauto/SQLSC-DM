SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [Staging].[GetBundleInfo] 
	@CourseID Int = 0
AS
	-- Preethi Ramanujam    10/31/2008  To get bundle information given a courseID
begin

    DECLARE @ErrorMsg VARCHAR(400)   --- Error message for error handling.
    DECLARE @DeBugCode TINYINT

    --- Check to make sure CatalogCodes are provided by the user.
    IF @DeBugCode = 1 PRINT 'Checking to make sure CourseID is provided by the user'

    DECLARE @Count INT, @Count2 INT

    If @CourseID > 0
     Begin
          SELECT @Count = COUNT(*)
          FROM Staging.MktCourse
          WHERE courseid = @CourseID
     end

    IF @Count = 0 or @CourseID = 0
    BEGIN 
          SET @ErrorMsg = 'CourseID ' + CONVERT(VARCHAR,@CourseID) + ' does not exist in Superstardw.dbo.MktCourse. Please Provide a valid CourseID'
          RAISERROR(@ErrorMsg,15,1)
          RETURN
    END

          SELECT @Count = COUNT(*)
          FROM Mapping.bundlecomponents
          WHERE courseid = @CourseID

    if @Count = 0 
    BEGIN
          SELECT @Count2 = COUNT(*)
          FROM Mapping.bundlecomponents
          WHERE BundleID = @CourseID

          IF @count2 = 0
             BEGIN
                SET @ErrorMsg = 'There is no Bundle for CourseID ' + CONVERT(VARCHAR,@CourseID)
                PRINT @ErrorMsg
                RETURN
             END
          ELSE
             BEGIN
                PRINT convert(varchar,@CourseID) + ' is a Bundle'
                select a.courseid, b.coursename, a.bundleID, c.coursename
                from Mapping.bundlecomponents a join
                      Staging.MktCourse b on a.courseid = b.courseid join
                      Staging.MktCourse c on a.bundleid = c.courseid
                where bundleid = @CourseID
                RETURN
             END
    END
end
GO
