SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CustomerOverlay_GetInputData]
	@ServerName varchar(30) = 'TTCDATAMART01'
AS
declare 
    @FinalTableName varchar(100),
    @SQLStatement nvarchar(500)
BEGIN
	set nocount on
	if object_id('Staging.TempCustomerOverlayInputData') is not null drop table Staging.TempCustomerOverlayInputData
    
    ;with 
    cteInitialOrderDate(CustomerID, DateOrdered) as
    (
    	select 
        	o.CustomerID,
            o.DateOrdered 
        from Marketing.DMPurchaseOrders o (nolock)
		where SequenceNum = 1
    ),
    cteDateLastPurchased(CustomerID, DateOrdered) as
    (
		select 
        	CustomerID, 
            MAX(dateordered) dateordered
		from Marketing.DMPurchaseOrders o (nolock)
		group by customerid
    )
    select a.CustomerID, a.Prefix, a.FirstName, a.MiddleName,
        a.LastName, a.Suffix, a.Address1, a.Address2, a.City, a.State, 
        a.PostalCode, a.CountryCode, a.PreferredCategory, a.CustomerSegment, 
        a.CustomerType, 
        dlp.DateOrdered as DateLastPurchased, -- convert(datetime,'') DateLastPurchased
		iod.DateOrdered as InitialOrderDate -- convert(datetime,'') InitialOrderDate
    into Staging.TempCustomerOverlayInputData
    from Marketing.CampaignCustomerSignature a (nolock) 
    left join Mapping.CustomerOverLay b (nolock) on a.Customerid = b.CustomerID
    left join cteInitialOrderDate iod on iod.CustomerID = a.CustomerID
    left join cteDateLastPurchased dlp on dlp.CustomerID = a.CustomerID
    where b.CustomerID is null
	and a.ComboID not like '%25-10000 Mo Inq%'
    and a.CountryCode like '%US%'
    
    -- Drop if we have sent this for overlay information
    delete a
    from Staging.TempCustomerOverlayInputData a join
		Archive.CustomerOverlay_Input_History b on a.customerid = b.customerid
		
	-- Add this data to history table
	insert into Archive.CustomerOverlay_Input_History
	select *, CONVERT(datetime,convert(varchar,getdate(),101))
	from Staging.TempCustomerOverlayInputData	
    
    set @FinalTableName = 'RFM..CustomerOverlay_Input_' + convert(varchar(8), getdate(), 112) 

    if object_id(@FinalTableName) is not null 
    begin
		set @SQLStatement = 'drop table ' + @FinalTableName
		exec sp_executesql @SQLStatement
    end
    
    set @SQLStatement = 'select * into ' + @FinalTableName + ' from Staging.TempCustomerOverlayInputData (nolock)'
	exec sp_executesql @SQLStatement
    
--   	set @SQLStatement = 'dtexec /f "\\Ttcdatamart01\etldax\CustomerOverlay.dtsx"' 
--   	exec xp_cmdshell @SQLStatement
    
	if object_id('Staging.TempCustomerOverlayInputData') is not null drop table Staging.TempCustomerOverlayInputData    
END
GO
