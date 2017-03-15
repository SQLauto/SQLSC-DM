SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE  PROC [Staging].[GetEmailReports]
	@TableName varchar(200), 
    @DatabaseName varchar(50) = 'rfm'
AS

-- Preethi Ramanujam 	10/31/2008	To get bundle information given a courseID

    DECLARE @SQLStatement nVARCHAR(MAX)

begin
	set nocount on

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    
  	if object_id('Staging.TempEmailReports') is not null
    drop table Staging.TempEmailReports
    
    set @SQLStatement = 'select * into Staging.TempEmailReports from ' + @DatabaseName + '..' + @TableName + ' (nolock)'
	exec sp_executesql @SQLStatement
    
    -- Generate Report 1: Counts by ComboID or RFM segments
    PRINT 'Generate Report 1: Counts by ComboID or RFM segments'

    SELECT 
	    rfc.SeqNum, 
        rfc.ComboID, 
        Count(Distinct CustomerID) AS CountOfCustomers
    FROM (select distinct SeqNum, ComboID from Mapping.rfmcombolookup) rfc 
    left outer join Staging.TempEmailReports Fnl on rfc.ComboID = Fnl.ComboID 
    GROUP BY rfc.SeqNum, rfc.ComboID
    ORDER BY rfc.SeqNum

    -- Generate Report 2: Counts by Adcode, Subjectline, EcampaignID
    PRINT 'Generate Report 2: Counts by Adcode, Subjectline, EcampaignID'

    SELECT 
    	fnl.AdCode, 
        mac.Name, 
        fnl.SubjectLine,
        Fnl.EcampaignID,
        COUNT(fnl.Customerid) AS TotalCount,
        COUNT(DISTINCT fnl.Customerid) AS UniqueCustCount
    FROM Staging.TempEmailReports fnl
    LEFT OUTER JOIN Staging.MktAdcodes mac ON fnl.adcode = mac.adcode
    GROUP BY fnl.AdCode, mac.Name, fnl.SubjectLine, Fnl.EcampaignID
    ORDER BY fnl.AdCode

    -- Generate Report 3: Counts by Adcode
    PRINT 'Generate Report 3: Counts by Adcode'

    SELECT 
    	fnl.AdCode, 
        mac.Name,
        COUNT(fnl.Customerid) AS TotalCount,
        COUNT(DISTINCT fnl.Customerid) AS UniqueCustCount
	FROM Staging.TempEmailReports fnl 
    LEFT OUTER JOIN Staging.MktAdcodes mac ON fnl.adcode = mac.adcode
    GROUP BY fnl.AdCode, mac.Name 
    ORDER BY fnl.AdCode

    -- Generate Report 4: Counts by RFM and by Adcode
    PRINT 'Generate Report 4: Counts by RFM and by Adcode'

    set @SQLStatement = STUFF(( SELECT DISTINCT
                                    '],[' + str(AdCode, 5)
                            FROM Staging.TempEmailReports
                            ORDER BY '],[' + str(AdCode, 5)
                            FOR XML PATH('')
                                        ), 1, 2, '') + ']'
    set @SQLStatement = '
    select * from
    (
        select distinct cl.SeqNum, cl.ComboID, em.Adcode, em.Customerid 
        from Mapping.RFMComboLookup cl (nolock)
        left join Staging.TempEmailReports em (nolock) on cl.ComboID = em.ComboID
    ) src
    pivot (count(src.CustomerID) for src.AdCode in (' + @SQLStatement + ')) pvt
    order by SeqNum'

    exec sp_executesql @SQLStatement

    -- Generate Report 5: List of Sample CustomerIDs
    PRINT 'Generate Report 5: List of Sample CustomerIDs'

    SELECT DISTINCT 
    	c.customerid,
        d.firstname,
        d.lastname,
        c.PreferredCategory,
        c.adcode
    FROM 
    (
	    SELECT MAX(DISTINCT customerid) AS customerid, PreferredCategory, Adcode
        FROM Staging.TempEmailReports
        GROUP BY PreferredCategory, Adcode
    ) c 
    JOIN Staging.TempEmailReports d ON c.customerid=d.customerid
    ORDER BY c.adcode, c.PreferredCategory, c.customerid
    	
    -- Generate Report 6: Check CountryCodes for the Email
    PRINT 'Generate Report 6: Check CountryCodes for the Email'

    SELECT 
    	Case 
        	when b.countrycode in ('CA','GB','USA','AU') then b.CountryCode
            else 'RestOfTheWorld'
        end as CountryCode, 
        Count(Distinct a.CustomerID)
        FROM Staging.TempEmailReports a 
        join marketing.campaigncustomersignature b on a.emailaddress = b.emailaddress
        GROUP BY 
        	Case 
            	when b.countrycode in ('CA','GB','USA','AU') then b.CountryCode
                 else 'RestOfTheWorld'
            end
        ORDER BY 1
    	
  	if object_id('Staging.TempEmailReports') is not null
    drop table Staging.TempEmailReports
    
end
GO
