SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Staging].[vw_MC_MD_ChannelRollup]
AS
   select *,
		case when md_channelid in (1,3,8,9) then 'Physical Mailing'
			when md_channelid in (6,7,44) then 'Email'
			when md_channelid in (11,12,13,14,47,54,55,56,57,58,57,58,59) then 'Digital Marketing'
			when md_channelid in (4) then 'Space Ads'
			when md_channelid in (15,16,17) then 'Web Default'
			else 'Other'
		end as MD_ChannelRU
   from mapping.mktdim_Channel


GO
