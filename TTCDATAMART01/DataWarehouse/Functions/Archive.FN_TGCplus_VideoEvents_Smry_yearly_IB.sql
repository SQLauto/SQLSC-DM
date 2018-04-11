SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Function [Archive].[FN_TGCplus_VideoEvents_Smry_yearly_IB] (@Year int)
RETURNS table
as
Return(
SELECT [UUID]
      ,[ID]
      ,[TSTAMP]
      ,[Month]
      ,[Year]
      ,[Week]
      ,[Platform]
      ,[useragent]
      ,[Vid]
      ,[courseid]
      ,[episodeNumber]
      ,[FilmType]
      ,[lectureRunTime]
      ,[CountryCode]
      ,[city]
      ,[State]
      ,[timezone]
      ,[plays]
      ,[pings]
      ,[MaxVPOS]
      ,[uip]
      ,[StreamedMins]
      ,[MinTstamp]
      ,[SeqNum]
      ,[Paid_SeqNum]
      , Row_number() over(partition by uuid order by [SeqNum])[SeqNum_Year]
      , case when [Paid_SeqNum] is not null then Row_number() over(partition by uuid order by [Paid_SeqNum])
		else null end as [Paid_SeqNum_Year]
  FROM [DataWarehouse].[Marketing].[TGCplus_Consumption_Smry]
  where [Year] = @Year
 
);
GO
