SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROC [Staging].[CreateHSMailFile] 
	@DropDate DATETIME,
	@AdcodeActive INT,
	@AdcodeSwamp INT,
	@Test VARCHAR(5) = 'Yes'
AS
/*- Proc Name: 	rfm.dbo.CreateHSMailFile */
/*- Purpose:	This creates mail file for House High School mailings */
/*- Input Parameters: @CatalogCode,@CatalogName,@DropDate,@PrimarySubject,@MaxSubjRank,*/
/*-		      @FnlTblName,@MailIPTbl,@AdcodeActive,@AdcodeSwamp,@AdcodeInq*/
/*- Tables Used: MarketingDM.dbo.ValidMailList*/
/*- Updates:*/
/*- Name		Date		Comments*/
/*- Preethi Ramanujam 	6/12/2007	New*/
/*-*/
begin
	set nocount on

    SELECT 'WELCOME TO HS MAIL PULL!!'

    SELECT 'IN THE HSMail'
    SELECT '@DropDate = ' + CONVERT(VARCHAR,@DropDate,101)

    SELECT 
        cs.CustomerID,
        ComboID,
        BuyerType,
        NewSeg,
        Name,
        a12mf,
        Concatenated,
        CustomerSegment,
        Frequency,
        FMPullDate, 
        @DropDate AS StartDate,
        Prefix,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        Address1 + ' '  + Address2 as Address1,
        Address3 as Address2,
        City,
        State,
        PostalCode,
        PreferredCategory2,
        CASE 
            WHEN CustomerSegment = 'Active' THEN @AdcodeActive
            ELSE @AdcodeSwamp
        END AS Adcode,
        FlagMail,
        cd.TTB
    into Staging.TempMailPull            
    FROM Marketing.CampaignCustomerSignature cs (nolock)
    left join Marketing.CustomerDynamicCourseRank cd (nolock) on cs.CustomerID = cd.CustomerID
    WHERE 
        BuyerType = 3
        AND FlagMail = 1
        AND FlagValidRegionUS = 1
        AND PublicLibrary = 0

    UNION

    SELECT DISTINCT 
        ccs.CustomerID,
        ccs.ComboID,
        ccs.BuyerType,
        ccs.NewSeg,
        ccs.Name,
        ccs.a12mf,
        ccs.Concatenated,
        ccs.CustomerSegment,
        ccs.Frequency,
        ccs.FMPullDate,  
        @DropDate AS StartDate,
        ccs.Prefix,
        ccs.FirstName,
        ccs.MiddleName,
        ccs.LastName,
        ccs.Suffix,
        ccs.Address1,
        ccs.Address2,
        ccs.City,
        ccs.State,
        ccs.PostalCode,
        ccs.PreferredCategory2,
        CASE 
            WHEN CustomerSegment = 'Active' THEN @AdcodeActive
            ELSE @AdcodeSwamp
        END AS Adcode,
        ccs.FlagMail,
        cd.TTB
    FROM Marketing.CampaignCustomerSignature ccs (nolock)
    left join Marketing.CustomerDynamicCourseRank cd (nolock) on ccs.CustomerID = cd.CustomerID    
    WHERE 
        ccs.BuyerType IN (4,5)
        AND ccs.FlagMail = 1
        AND ccs.FlagValidRegionUS = 1
        AND ccs.PublicLibrary = 0
        AND ccs.HS = 1

    /*- Update MailingHistory Table */
    IF UPPER(@Test) = 'NO'
    BEGIN
        INSERT INTO Archive.MailingHistory
                 SELECT DISTINCT Customerid, AdCode, StartDate, NewSeg, Name, A12mf, Concatenated, 0
                 FROM Staging.TempMailPull
    END

end
GO
