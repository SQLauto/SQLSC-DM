SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROC [Staging].[GetMailReports]
	@TableName varchar(200), 
    @DatabaseName varchar(50) = 'rfm'
AS
-- Preethi Ramanujam 	10/31/2008	To get bundle information given a courseID

	DECLARE 
    	@ErrorMsg VARCHAR(400),   --- Error message for error handling.
		@DeBugCode TINYINT,
		@SQLStatement nVARCHAR(max), 
        @MailPiece VARCHAR(50), 
        @CatalogCode INT, 
        @CatalogName VARCHAR(50)
begin    
	set nocount on
    
  	if object_id('Staging.TempMailReports') is not null
    drop table Staging.TempMailReports
    
    set @SQLStatement = 'select * into Staging.TempMailReports from ' + @DatabaseName + '..' + @TableName + ' (nolock)'
	exec sp_executesql @SQLStatement

    SET @DeBugCode = 1

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

    SELECT @CatalogCode = CatalogCode
    FROM Staging.MktAdcodes 
    WHERE Adcode IN (SELECT DISTINCT Adcode FROM Staging.TempMailReports)
    and Description like '%Control%'
    
/*
    SELECT @MailPiece = v.MD_CampaignDesc
    FROM Mapping.vwAdcodesAll v
    where v.CatalogCode = @CatalogCode
    
    SK 2/6/12 - changed per PR request to:
*/    
    select 
    	@MailPiece = 
        case 
            when cc.DaxMktPromotionType in (1, 6, 7) then 'Catalogs'
            when cc.DaxMktPromotionType = 2 then 'Swamp'
            when cc.DaxMktPromotionType = 3 then 'Magazines'        
            when cc.DaxMktPromotionType in (4, 5, 14) then 'Magalogs'                                        
            when cc.DaxMktPromotionType = 8 and cc.DaxMktCampaign = 87 then 'JFYSimple'
            when cc.DaxMktPromotionType = 8 and cc.DaxMktCampaign = 88 then 'JFYFormatSpecific'        
            when cc.DaxMktPromotionType = 8 and cc.DaxMktCampaign = 89 then 'JFYSubjectSpecific'                
            when cc.DaxMktPromotionType = 10 then 'Newsletters'                
            when cc.DaxMktPromotionType = 22 then 'Library'
        end,
        @CatalogName = Name
    from Staging.MktCatalogCodes cc (nolock)
    where CatalogCode = @CatalogCode
    			
    Print '@CatalogName = ' + @CatalogName
    Print '@MailPiece = ' + @MailPiece

    -----------------------------------------------------------------------------------------------------------------
    -- Generate Report 1: Counts by RFM segments
    PRINT 'Generate Report 1: Counts by RFM segments'

    SELECT 
    	rfms.NewSeg,
        rfms.Name,
        rfms.A12mf,
        a.StartDate,
        a.FMPullDate, 
        count(a.customerid) as CustCount
    FROM
    (SELECT DISTINCT csm.newseg,csm.name,csm.a12mf
    FROM
    Mapping.rfmComboLookUP csm)rfms LEFT OUTER JOIN 
	Staging.TempMailReports  a
    ON  ISNULL(rfms.newseg,'')=ISNULL(a.newseg,'') and ISNULL(rfms.name,'')=ISNULL(a.name,'') and ISNULL(rfms.a12mf,'')=ISNULL(a.a12mf,'')
    GROUP BY rfms.newseg,rfms.name,rfms.a12mf,a.startdate,a.fmpulldate
    ORDER BY 1,2,3

    -----------------------------------------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------------------------------------
    -- Generate Report 2: Counts by ComboID
    PRINT 'Generate Report 2: Counts by ComboID'

    SELECT 
    	rfc.SeqNum, 
        rfc.ComboID, 
        fnl.StartDate, 
        fnl.FMPullDate, 
        Count(Distinct CustomerID) AS CountOfCustomers
    FROM (select distinct SeqNum,ComboID from Mapping.rfmcombolookup)rfc 
    left outer join Staging.TempMailReports Fnl on rfc.ComboID = Fnl.ComboID 
    GROUP BY rfc.SeqNum, rfc.ComboID, fnl.StartDate, fnl.FMPullDate
    ORDER BY rfc.SeqNum

    -----------------------------------------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------------------------------------
    -- Generate Report 3: Counts by RFM and Subject Rank for subject based mailings

    IF @CatalogName not like '%Summer%HS%' AND @CatalogName not like '%NC%' AND @CatalogName not like '%New%Course%'
    BEGIN
    IF @MailPiece like '%Magazine%' OR @MailPiece like '%Magalog%'
       BEGIN
        PRINT 'Generate Report 3a: Counts by RFM and Subject Rank for subject based mailings'
    	
        SELECT 'Generate Report 3a: Counts by RFM and Subject Rank for subject based mailings'

        -- Get all the different subject ranks in the table
        PRINT 'Get all the different subject ranks in the table'
        
	  	if object_id('Staging.TempSubjRankList') is not null drop table Staging.TempSubjRankList
        
        SELECT DISTINCT SubjRank 
        INTO Staging.TempSubjRankList 
        FROM Staging.TempMailReports (nolock)
    	
        DECLARE @SQLStatement1Part1 VARCHAR(4000), @SQLStatement1Part2 VARCHAR(4000), @SQLStatement1Part3 VARCHAR(4000)
        DECLARE @SQLStatement1Final VARCHAR(8000)
        DECLARE @TotalSubjRanks INT, @TotalSubjRankCounter INT
        DECLARE @ColNumSR VARCHAR(5), @ColNumCountSR VARCHAR(15)

        SET @SQLStatement1Final = 'SELECT rfms.NewSeg, rfms.Name, rfms.A12mf, s1.StartDate, s1.FMPullDate, ' +  char(13) + char(10)

        SET @SQLStatement1Part1 = ' FROM
                (SELECT distinct NewSeg,Name,A12mf 
                FROM Marketing.customersubjectmatrix)rfms left outer join ' + char(13) + char(10)

        SET @SQLStatement1Part2 = ''
        SET @SQLStatement1Part3 = ''
    	
        SELECT @TotalSubjRanks = Count(Distinct SubjRank)
        FROM Staging.TempSubjRankList
    	
        SET @TotalSubjRankCounter = 1
    	
        WHILE @TotalSubjRanks >= @TotalSubjRankCounter
           BEGIN
            SET @ColNumSR = 'S' + convert(varchar, @TotalSubjRankCounter)
            SET @ColNumCountSR = @ColNumSR + 'Count'
    	
            SET @SQLStatement1Part2 = @SQLStatement1Part2 + ' ' + @ColNumSR + '.Counts AS ' + @ColNumCountSR + ',' + char(13) + char(10)
    	
            SET @TotalSubjRankCounter = @TotalSubjRankCounter + 1
           END

        SET @SQLStatement1Part2 = SUBSTRING(@SQLStatement1Part2, 1, LEN(@SQLStatement1Part2) - 3)
        PRINT '@SQLStatement1Part2 = ' + @SQLStatement1Part2
        PRINT '##########################################################'
    	
        DECLARE @SubjRank VARCHAR(5), @CounterSR INT
        SET @CounterSR = 0
    	
        DECLARE MyCursor1 CURSOR
        FOR
        SELECT Distinct subjrank
        FROM Staging.TempSubjRankList
        ORDER BY 1
    	
        OPEN MyCursor1
        FETCH NEXT FROM MyCursor1 INTO @SubjRank
    	
    	
        WHILE @@FETCH_STATUS = 0
        BEGIN
    	
            SET @SQLStatement1Part3 = @SQLStatement1Part3 + char(13) + char(10) + 
                    '(SELECT NewSeg, Name, A12mf, StartDate, FMPullDate,
                    COUNT(CustomerID) AS Counts
                    FROM Staging.TempMailReports
                     WHERE subjrank = ''' + @SubjRank +
                    ''' AND ComboID NOT LIKE ''Use%''' + char(13) + char(10) +
                    'GROUP BY NewSeg, Name, A12mf, StartDate, FMPullDate)' + @SubjRank +
                    ' ON  ISNULL(rfms.newseg,'''')=ISNULL(' + @SubjRank + '.newseg,'''') 
                     AND ISNULL(rfms.name,'''')=ISNULL(' + @SubjRank + '.name,'''') 
                     AND ISNULL(rfms.a12mf,'''')=ISNULL(' + @SubjRank + '.a12mf,'''') 
                    LEFT OUTER JOIN '
    		
            FETCH NEXT FROM MyCursor1 INTO @SubjRank
        END
        CLOSE MyCursor1
        DEALLOCATE MyCursor1

        SET @SQLStatement1Part3 = SUBSTRING(@SQLStatement1Part3, 1, LEN(@SQLStatement1Part3) - 17)
        PRINT '@SQLStatement1Part3 = ' + @SQLStatement1Part3
        PRINT '##########################################################'

        SET @SQLStatement1Final = @SQLStatement1Final + @SQLStatement1Part2 + @SQLStatement1Part1 + @SQLStatement1Part3 + ' ORDER BY 1, 2, 3'
    -- 	PRINT '@SQLStatement1Final = ' + @SQLStatement1Final

        PRINT 'Executing ' + @SQLStatement1Final
        EXEC (@SQLStatement1Final)
    -----------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------
    --	Generate Report 3b: Counts by ComboID and Subject Rank for subject based mailings
        PRINT 'Generate Report 3b: Counts by ComboID and Subject Rank for subject based mailings'

        SELECT 'Generate Report 3b: Counts by ComboID and Subject Rank for subject based mailings'

        SET @SQLStatement1Final = ''
        SET @SQLStatement1Part1 = ''

        SET @SQLStatement1Final = 'SELECT rfms.SeqNum, rfms.ComboID, S1.StartDate, S1.FMPullDate, ' +  char(13) + char(10)

        SET @SQLStatement1Part1 = ' FROM
                    (SELECT Distinct SeqNum, ComboID
                    FROM Mapping.rfmcombolookup)rfms LEFT OUTER JOIN ' + char(13) + char(10)

        SET @SQLStatement1Part2 = ''
        SET @SQLStatement1Part3 = ''
    	
        SELECT @TotalSubjRanks = Count(Distinct SubjRank)
        FROM Staging.TempSubjRankList
    	
        SET @TotalSubjRankCounter = 1
    	
        WHILE @TotalSubjRanks >= @TotalSubjRankCounter
           BEGIN
            SET @ColNumSR = 'S' + convert(varchar, @TotalSubjRankCounter)
            SET @ColNumCountSR = @ColNumSR + 'Count'
    	
            SET @SQLStatement1Part2 = @SQLStatement1Part2 + ' ' + @ColNumSR + '.Counts AS ' + @ColNumCountSR + ',' + char(13) + char(10)
    	
            SET @TotalSubjRankCounter = @TotalSubjRankCounter + 1
           END

        SET @SQLStatement1Part2 = SUBSTRING(@SQLStatement1Part2, 1, LEN(@SQLStatement1Part2) - 3)
        PRINT '@SQLStatement1Part2 = ' + @SQLStatement1Part2
        PRINT '##########################################################'
    	

        SET @CounterSR = 0
    	
        DECLARE MyCursor1 CURSOR
        FOR
        SELECT Distinct subjrank
        FROM Staging.TempSubjRankList
        ORDER BY 1
    	
        OPEN MyCursor1
        FETCH NEXT FROM MyCursor1 INTO @SubjRank
    	
    	
        WHILE @@FETCH_STATUS = 0
        BEGIN
    	
            SET @SQLStatement1Part3 = @SQLStatement1Part3 + char(13) + char(10) + 
                    '(SELECT a.SeqNum, A.ComboID, B.StartDate,
                        B.FmPullDate, Count(b.CustomerID) AS Counts
                          FROM (SELECT DISTINCT SeqNum, ComboID FROM rfm..rfmcombolookup)A LEFT OUTER JOIN 
                          Staging.TempMailReports b ON a.ComboID = b.ComboID	
                    WHERE SubjRank = ''' + @SubjRank + ''' GROUP BY a.SeqNum, A.ComboID, B.StartDate,
                        B.FmPullDate)' + @SubjRank +
                    ' ON rfms.ComboID = ' + @SubjRank + '.ComboID LEFT OUTER JOIN'
    				
    		
            FETCH NEXT FROM MyCursor1 INTO @SubjRank
        END
        CLOSE MyCursor1
        DEALLOCATE MyCursor1

        SET @SQLStatement1Part3 = SUBSTRING(@SQLStatement1Part3, 1, LEN(@SQLStatement1Part3) - 16)
        PRINT '@SQLStatement1Part3 = ' + @SQLStatement1Part3
        PRINT '##########################################################'

        SET @SQLStatement1Final = @SQLStatement1Final + @SQLStatement1Part2 + @SQLStatement1Part1 + @SQLStatement1Part3 + ' ORDER BY 1, 2, 3'

        PRINT 'Executing ' + @SQLStatement1Final
        EXEC (@SQLStatement1Final)

    -----------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------
    --	Report 3C: By SubjectRankAdcode 1
        PRINT 'Report 3C: By SubjectRankAdcode 1'

        SELECT 
        	a.SubjRank, 
            a.Adcode, 
            b.Name, 
            COUNT(a.customerid) AS CustCount
        FROM Staging.TempMailReports A 
        LEFT OUTER JOIN Staging.MktAdcodes B ON a.Adcode = b.Adcode
        GROUP BY a.subjrank,a.adcode,b.name
        ORDER BY 2,1

    -----------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------
    --	Report 3D: By SubjectRankAdcode 1
        PRINT 'Report 3D: By SubjectRankAdcode 1'

        SELECT 
        	COUNT(CustomerID) AS Count, 
            SubjRank, 
            NewSeg, 
            Name, 
            A12mf, 
            Adcode, 
            ComboID
        FROM Staging.TempMailReports 
        GROUP BY SubjRank, NewSeg, Name, A12mf, Adcode, ComboID
        ORDER BY 2,6,3,4,5

    -----------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------
    --	Report 3E: By Subject Category 1
        PRINT 'Report 3E: By Subject Category 1'

        --- Get other parameters based on the CatalogCode.
        DECLARE @PrimarySubject VARCHAR(5)
        
		if object_id('Staging.TempCatalogCode') is not null drop table Staging.TempCatalogCode        

        SELECT DISTINCT aca.CatalogCode 
        INTO Staging.TempCatalogCode 
        FROM Staging.TempMailReports fnl 
        JOIN Mapping.vwAdcodesAll aca ON fnl.Adcode = aca.Adcode
        WHERE aca.AdcodeName LIKE '%Active Control%'

        SELECT DISTINCT @PrimarySubject = CASE WHEN LEFT(Name,CHARINDEX(' ',Name)-1) = 'LT' THEN 'LIT'
                           WHEN LEFT(Name,CHARINDEX(' ',Name)-1) = 'RG' THEN 'RL'
                           WHEN LEFT(Name,CHARINDEX(' ',Name)-1) = 'Econ' THEN 'EC'
                           ELSE LEFT(Name,CHARINDEX(' ',Name)-1)
                      END
        FROM Staging.MktCatalogCodes
        WHERE CatalogCode IN (SELECT CatalogCode FROM Staging.TempCatalogCode)

		if object_id('Staging.TempSubjectList') is not null drop table Staging.TempSubjectList        

        SELECT PrimarySubjAbbr AS SubjectCategory, CRSubjRank
        INTO Staging.TempSubjectList
        FROM Mapping.subjectcorrelation (nolock)
        WHERE CRSubjAbbr = @PrimarySubject
        ORDER BY CRSubjRank

        SELECT * FROM Staging.TempSubjectList (nolock)
    -----------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------
    --	Report 3F: By Subject Category 2
        PRINT 'Report 3F: By Subject Category 2'
        SELECT 'Report 3F: By Subject Category 2'

    -- 	DECLARE @SQLStatement1Part1 VARCHAR(4000)
        SET @SQLStatement1Part1 =''

        SELECT @SQLStatement1Part1 = @SQLStatement1Part1 + SubjectCategory + ', '
        FROM Staging.TempSubjectList 
            WHERE SubjectCategory <> 'REST'
    	
        SELECT @SQLStatement1Part1 = SUBSTRING(@SQLStatement1Part1,1,LEN(@SQLStatement1Part1)-1)
        SELECT @SQLStatement1Part1 

        SET @SQLStatement = 'SELECT COUNT(CustomerID) AS Counts, SubjRank, ' + @SQLStatement1Part1 + 
               ' FROM Staging.TempMailReports
                GROUP BY SubjRank, ' + @SQLStatement1Part1 + 
               ' ORDER BY SubjRank, ' + @SQLStatement1Part1

        PRINT (@SQLStatement)
        EXEC (@SQLStatement)	

       END
    ELSE
       PRINT 'Not Subject Based Mailing. So, Report 3 will not be needed'
    END

    -----------------------------------------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------------------------------------
    -- Generate Report 4: Counts by Adcode
    PRINT 'Generate Report 4: Counts by Adcode'

    SELECT 'Generate Report 4: Counts by Adcode'
    
  	if object_id('Staging.TempAdcodesList') is not null drop table Staging.TempAdcodesList

    SELECT 
    	fnl.AdCode, mac.Name, Mac.CatalogCode,
        COUNT(fnl.Customerid) AS TotalCount
    into Staging.TempAdcodesList
    from Staging.TempMailReports fnl 
    LEFT OUTER JOIN Staging.MktAdcodes mac ON fnl.adcode = mac.adcode
    GROUP BY fnl.AdCode, mac.Name , mac.CatalogCode
    ORDER BY fnl.AdCode

    select * from Staging.TempAdcodesList
    -----------------------------------------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------------------------------------
    -- Generate Report 5: Counts by RFM and by Adcode
    PRINT 'Generate Report 5: Counts by RFM and by Adcode'

    SELECT 'Generate Report 5: Counts by RFM and by Adcode'

    set @SQLStatement = STUFF(( SELECT DISTINCT
                                    '],[' + str(AdCode, 5)
                            FROM Staging.TempMailReports
                            ORDER BY '],[' + str(AdCode, 5)
                            FOR XML PATH('')
                                        ), 1, 2, '') + ']'
    set @SQLStatement = '
    select * from
    (
        select distinct cl.SeqNum, cl.ComboID, em.Adcode, em.Customerid 
        from Mapping.RFMComboLookup cl (nolock)
        left join Staging.TempMailReports em (nolock) on cl.ComboID = em.ComboID
    ) src
    pivot (count(src.CustomerID) for src.AdCode in (' + @SQLStatement + ')) pvt
    order by SeqNum'

    exec sp_executesql @SQLStatement

/*  	if object_id('Staging.TempMailReports') is not null drop table Staging.TempMailReports
    if object_id('Staging.TempSubjRankList') is not null drop table Staging.TempSubjRankList
	if object_id('Staging.TempCatalogCode') is not null drop table Staging.TempCatalogCode            
	if object_id('Staging.TempSubjectList') is not null drop table Staging.TempSubjectList            
  	if object_id('Staging.TempAdcodesList') is not null drop table Staging.TempAdcodesList    */
end
GO
