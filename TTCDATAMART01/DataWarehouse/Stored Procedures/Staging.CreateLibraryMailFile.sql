SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*- Proc Name: 	rfm.dbo.CreateLibraryMailFile*/
/*- Purpose:	This creates mail file for Library Catalog mailings */
/*- Input Parameters: @CatalogCode,@DropDate,@FnlTblName,@MailIPTbl,@AdcodeActive*/
/*- Updates:*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	6/20/2007	New*/
/*-*/

CREATE  PROC [Staging].[CreateLibraryMailFile]
	@DropDate DATETIME,
	@AdcodeActive INT
AS
begin

    SELECT 'WELCOME TO LIBRARY MAIL PULL!!'

    SELECT '@DropDate = ' + CONVERT(VARCHAR,@DropDate,101)

    SELECT 
        cs.CustomerID, 
        Prefix,
        CASE 
            WHEN FirstName LIKE '%Accou%' OR FirstName LIKE '%LifeLong%' OR LastName LIKE '%Accou%' THEN 'Purchasing/Acquisitions'
             ELSE FirstName
        END AS FirstName,
        MiddleName,
        CASE WHEN FirstName LIKE '%Accou%' OR FirstName LIKE '%LifeLong%' OR LastName LIKE '%Accou%' THEN 'Department'
             ELSE LastName
        END AS LastName,
        Suffix,
        Address1 + ' '  + Address2 as Address1,
        Address3 as Address2,
        City,
        State,
        PostalCode, 
        @AdCodeActive AS Adcode, 
        @DropDate AS StartDate,
        FlagMail,
        cd.TTB
    into Staging.TempMailPull            
    FROM Marketing.CampaignCustomerSignature cs (nolock)
    left join Marketing.CustomerDynamicCourseRank cd (nolock) on cs.CustomerID = cd.CustomerID
    WHERE FlagMail = 1
    AND FlagValidRegionUS = 1
    AND PublicLibrary = 1

end
GO
