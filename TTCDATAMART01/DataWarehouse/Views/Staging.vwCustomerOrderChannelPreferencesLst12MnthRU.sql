SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Staging].[vwCustomerOrderChannelPreferencesLst12MnthRU]
AS
   -- with cteMRO(CustomerID, MD_ChannelRU, MD_Channel, SumParts, DateOrdered) as
    with cteMRO(CustomerID, MD_ChannelRU, SumParts, DateOrdered) as
    (
        select
            CustomerID, 
			case when b.ChannelID in (11,12,13,14,47,54,55,56,57,58) then 'Digital Marketing'
							when b.ChannelID in (6,7,44) then 'Email'
							when b.ChannelID in (1,2,3,8,9) then 'Physical Mailing'
							when b.ChannelID in (4) then 'SpaceAds'
							when b.ChannelID in (15,16,17) then 'Web Default'
							else 'Other'
						end as MD_ChannelRU,
           -- isnull(b.MD_Channel,'X') MD_Channel,
            sum(Parts) as SumParts,
            max(DateOrdered)
        from Staging.MostRecent3OrdersLst12MnthCDCR (nolock) a join
			Mapping.vwAdcodesAll b on a.Adcode = b.AdCode
        group by CustomerID,
			case when b.ChannelID in (11,12,13,14,47,54,55,56,57,58) then 'Digital Marketing'
				when b.ChannelID in (6,7,44) then 'Email'
				when b.ChannelID in (1,2,3,8,9) then 'Physical Mailing'
				when b.ChannelID in (4) then 'SpaceAds'
				when b.ChannelID in (15,16,17) then 'Web Default'
				else 'Other'
			end--,
            --isnull(b.MD_Channel,'X') 
    )
    select 
        CustomerID, 
		MD_ChannelRU,
    --    MD_Channel,
        rank() over (partition by CustomerID order by SumParts desc, DateOrdered desc) RankNum            
    from cteMRO





GO
