SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [Staging].[SP_MC_LoadAllOrdersTGCPref_LTD]
	@AsOfDate datetime = null
AS
BEGIN
	set nocount on
    set @AsOfDate = isnull(@AsOfDate, getdate())    

    select *
    into #MROData
    from Staging.MC_AllOrdersTGCPref_LTD (nolock)
    where 1=2

    insert into #MROData
    (
        CustomerID, 
        OrderID,     
        DateOrdered, 
		Adcode,
		MD_ChannelID,
		MD_Channel,
		MD_ChannelRU,
		PhysclMail_ChnlRU,
		SpaceAds_ChnlRU,
		DgtlMrktng_ChnlRU,
		Email_ChnlRU,
		WebDefault_ChnlRU,
		Other_ChnlRU,
        OrderItemID, 
        CourseID,
        Parts,
        SubjectCategory2,
        OrderSource,
		PhoneOS,
		WebOS,
		EmailOS,
		MailOS,
		OtherOS,
        FormatMedia,
		DVD,
		CD,
		DigitalVideo,
		DigitalAudio,
		VideoTape,
		AudioTape,
        FormatAV,
        FormatPD,
		AsOfDate
    )
    select 
        ccp.CustomerID,
        ccp.OrderID,
        ccp.DateOrdered,
		ccp.Adcode,
		ccp.MD_ChannelID,
		ccp.MD_Channel,
		ccp.MD_ChannelRU,
		case when ccp.MD_ChannelRU in ('Physical Mailing') then 1 else 0 end PhysclMail_ChnlRU,
		case when ccp.MD_ChannelRU in ('SpaceAds') then 1 else 0 end SpaceAds_ChnlRU,
		case when ccp.MD_ChannelRU in ('Digital Marketing') then 1 else 0 end DgtlMrktng_ChnlRU,
		case when ccp.MD_ChannelRU in ('Email') then 1 else 0 end Email_ChnlRU,
		case when ccp.MD_ChannelRU in ('Web Default') then 1 else 0 end WebDefault_ChnlRU,
		case when ccp.MD_ChannelRU in ('Other') then 1 else 0 end Other_ChnlRU,
        oi.OrderItemID,
        oi.CourseID,
        oi.TotalParts as Parts,
        oi.SubjectCategory2,
        ccp.OrderSource,
		case when ccp.OrderSource in ('P') then 1 else 0 end PhoneOS,
		case when ccp.OrderSource in ('W') then 1 else 0 end WebOS,
		case when ccp.OrderSource in ('E') then 1 else 0 end EmailOS,
		case when ccp.OrderSource in ('M') then 1 else 0 end MailOS,
		case when ccp.OrderSource not in ('P','W','E','M') then 1 else 0 end OtherOS,
        oi.FormatMedia,
		case when oi.FormatMedia in ('M','D') then 1 else 0 end DVD,
		case when oi.FormatMedia in ('M','C') then 1 else 0 end CD,
		case when oi.FormatMedia in ('DV') then 1 else 0 end DigitalVideo,
		case when oi.FormatMedia in ('DL') then 1 else 0 end DigitalAudio,
		case when oi.FormatMedia in ('V') then 1 else 0 end VideoTape,
		case when oi.FormatMedia in ('A') then 1 else 0 end AudioTape,
        oi.FormatAV,
        case when left(oi.StockItemID,2) in ('DA','DV') then 'Digital' else 'Physical' end as FormatPD,
		ccp.AsOfDate
    from 
    (
    	select distinct  
            po.CustomerID, 
            po.OrderID, 
            po.DateOrdered,
            po.OrderSource,
			po.Adcode,
			va.ChannelID as MD_ChannelID,
			va.MD_Channel,
			va.MD_ChannelRU,
			-- '3/1/2013' as AsOfDate
			@AsOfDate as AsOfDate
			--dense_rank() over (partition by po.CustomerID order by po.DateOrdered desc) as OrderRecencyRank      
	    from Marketing.DMPurchaseOrdersIgnoreReturns po (nolock)
		left join Mapping.vwAdcodesAll va on po.adcode = va.AdCode
		where po.DateOrdered < @AsOfDate
    	--where po.DateOrdered < '3/1/2018' --@AsOfDate
		--where po.customerid in (50347245,40485215,41041218)
    ) ccp
    join Staging.ValidPurchaseOrderItemsIgnoreReturns oi (nolock) on ccp.OrderID = oi.OrderID
    where oi.FormatMedia <> 'T'

		truncate table Staging.MC_AllOrdersTGCPref_LTD
    	insert into Staging.MC_AllOrdersTGCPref_LTD
	    select * from #MROData (nolock)

		---Add other variables from excel


end

GO
