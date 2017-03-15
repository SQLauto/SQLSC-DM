SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[sp_ImportMagentoCoursesToDataMart]
AS

/* This routine is used to export courses from the Magento web site to Datamart.
   Date Written: 2014-05-19 J.C. Pack, TGC
   Last Updated: 
				 			                
*/

SET NOCOUNT ON 

TRUNCATE TABLE Magento_CourseProfessors


SELECT * INTO #ImportCourses FROM Magento_Courses WHERE CourseID = 1 AND CourseID = 0

DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX), @pKey AS INT

DECLARE cur_ProcessCourses INSENSITIVE CURSOR FOR
	SELECT TOP 5 pkey, XML_Data 
	FROM MagentoCourseImports
	WHERE ImportStatus = 0
	ORDER BY CreateDate
OPEN cur_ProcessCourses
FETCH NEXT FROM cur_ProcessCourses INTO @pKey, @XML
WHILE @@fetch_status = 0
BEGIN
	-- Testing code:
	
	--SELECT TOP 1 @pkey = pkey, @XML = XML_Data 
	--FROM MagentoCourseImports
	--WHERE ImportStatus = 0
	--ORDER BY CreateDate

	
	EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML

	SELECT DISTINCT Sku, CourseID, Store, Category, Bibliography,
		CourseSummary, Description, Meta_Description,
		Meta_Keyword, Meta_Title, Name, Short_Description,
		url_key, url_path
	INTO #tmpCourses
	FROM OPENXML(@hDoc, 'products/product')
	WITH 
	(
	Sku varchar(100) 'sku',
	CourseID int 'course_id',
	Store varchar(255) 'store',
	Category varchar(255) 'category',
	Bibliography varchar(255) 'bibliography',
	CourseSummary varchar(max) 'course_summary',
	Description varchar(max) 'description',
	Meta_Description varchar(max) 'meta_description',
	Meta_Keyword varchar(max) 'meta_keyword',
	Meta_Title varchar(max) 'meta_title',
	Name varchar(250) 'name',
	Short_Description varchar(max) 'short_description',
	url_key varchar(1000) 'url_key',
	url_path varchar(1000) 'url_path'
	)

	SELECT DISTINCT CourseID, Professor, sku
	INTO #tmpProfessors
	FROM OPENXML(@hDoc, 'products/product/professors')
	WITH 
	(
	CourseID int '../course_id',
	Professor varchar(250) 'professor',
	sku varchar(100) '../sku'
	)

	EXEC sp_xml_removedocument @hDoc -- Need to do this to free up server memory, best practice is to do ASAP after select

	TRUNCATE TABLE #ImportCourses

	INSERT INTO #ImportCourses
	SELECT DISTINCT CourseID, Store, Category, Bibliography,
		CourseSummary, Description, Meta_Description,
		Meta_Keyword, Meta_Title, Name, Short_Description,
		url_key, url_path
	FROM #tmpCourses 
	WHERE sku=convert(varchar(100), courseid)
	AND courseID BETWEEN 100 AND 999999
	
	MERGE Magento_Courses AS Dest

	USING #ImportCourses AS Import

	ON (Dest.CourseID = Import.CourseID)

	WHEN NOT MATCHED BY TARGET

		THEN INSERT
		
		(CourseID
		,Store
		,Category
		,Bibliography
		,CourseSummary
		,Description
		,Meta_Description
		,Meta_Keyword
		,Meta_Title
		,Name
		,Short_Description
		,url_key
		,url_path
		)
		
		VALUES
		
		(Import.CourseID
		,Import.Store
		,Import.Category
		,Import.Bibliography
		,Import.CourseSummary
		,Import.Description
		,Import.Meta_Description
		,Import.Meta_Keyword
		,Import.Meta_Title
		,Import.Name
		,Import.Short_Description
		,Import.url_key
		,Import.url_path	
		)
		
	WHEN MATCHED AND

		(Dest.Store <> Import.Store
		OR Dest.Category <> Import.Category
		OR Dest.Bibliography <> Import.Bibliography
		OR Dest.CourseSummary <> Import.CourseSummary
		OR Dest.Description <> Import.Description
		OR Dest.Meta_Description <> Import.Meta_Description
		OR Dest.Meta_Keyword <> Import.Meta_Keyword
		OR Dest.Meta_Title <> Import.Meta_Title
		OR Dest.Name <> Import.Name
		OR Dest.Short_Description <> Import.Short_Description
		OR Dest.url_key <> Import.url_key
		OR Dest.url_path <> Import.url_path
		)
		
		THEN UPDATE
		
		SET Dest.Store = Import.Store
		, Dest.Category = Import.Category
		, Dest.Bibliography = Import.Bibliography
		, Dest.CourseSummary = Import.CourseSummary
		, Dest.Description = Import.Description
		, Dest.Meta_Description = Import.Meta_Description
		, Dest.Meta_Keyword = Import.Meta_Keyword
		, Dest.Meta_Title = Import.Meta_Title
		, Dest.Name = Import.Name
		, Dest.Short_Description = Import.Short_Description
		, Dest.url_key = Import.url_key
		, Dest.url_path = Import.url_path
	;
	

	INSERT INTO Magento_CourseProfessors
	SELECT DISTINCT CourseID, Professor
	FROM #tmpProfessors 
	WHERE sku=convert(varchar(100), courseid)
	AND courseID BETWEEN 100 AND 999999
	
	DROP TABLE #tmpCourses
	DROP TABLE #tmpProfessors
	
	UPDATE MagentoCourseImports
	SET ImportStatus = 1
	WHERE pkey = @pKey

FETCH NEXT FROM cur_ProcessCourses INTO @pKey, @XML
END
DEALLOCATE cur_ProcessCourses
GO
