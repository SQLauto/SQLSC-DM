SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Staging].[vwMktDimChannelRollup]
AS
    select *, 
		case when MD_ChannelID in (11,12,13,14,47,53,54,55,56,57,58) then 'Digital Marketing'
			when MD_ChannelID in (6,7,44) then 'Email'
			when MD_ChannelID in (1,2,3,8,9) then 'Physical Mailing'
			when MD_ChannelID in (4) then 'SpaceAds'
			when MD_ChannelID in (15,16,17) then 'Web Default'
			else 'Other'
		end as MD_ChannelRU
    from Mapping.MktDim_Channel
    

GO
