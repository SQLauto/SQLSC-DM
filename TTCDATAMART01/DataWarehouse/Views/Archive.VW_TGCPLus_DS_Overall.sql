SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create View [Archive].[VW_TGCPLus_DS_Overall]
as

Select MinDSDate
,SUM(Total)Total
--DS0
,SUM(DS0Counts)DS0Counts
, 1-(Sum(DS0Counts)*1./ SUM(Total)) as DS0ChurnPCT
,Sum(DS0Counts)*1./ SUM(Total) as DS0RetentionPCT
--DS1
,SUM(DS1Counts)DS1Counts
, 1-(Sum(DS1Counts)*1./ SUM(Total)) as DS1ChurnPCT
,Sum(DS1Counts)*1./ SUM(Total) as DS1RetentionPCT
--DS2
,SUM(DS2Counts)DS2Counts
, 1-(Sum(DS2Counts)*1./ SUM(Total)) as DS2ChurnPCT
,Sum(DS2Counts)*1./ SUM(Total) as DS2RetentionPCT
--DS3
,SUM(DS3Counts)DS3Counts
, 1-(Sum(DS3Counts)*1./ SUM(Total)) as DS3ChurnPCT
,Sum(DS3Counts)*1./ SUM(Total) as DS3RetentionPCT
--DS4
,SUM(DS4Counts)DS4Counts
, 1-(Sum(DS4Counts)*1./ SUM(Total)) as DS4ChurnPCT
,Sum(DS4Counts)*1./ SUM(Total) as DS4RetentionPCT
--DS5
,SUM(DS5Counts)DS5Counts
, 1-(Sum(DS5Counts)*1./ SUM(Total)) as DS5ChurnPCT
,Sum(DS5Counts)*1./ SUM(Total) as DS5RetentionPCT
--DS6
,SUM(DS6Counts)DS6Counts
, 1-(Sum(DS6Counts)*1./ SUM(Total)) as DS6ChurnPCT
,Sum(DS6Counts)*1./ SUM(Total) as DS6RetentionPCT
--DS7
,SUM(DS7Counts)DS7Counts
, 1-(Sum(DS7Counts)*1./ SUM(Total)) as DS7ChurnPCT
,Sum(DS7Counts)*1./ SUM(Total) as DS7RetentionPCT
--DS8
,SUM(DS8Counts)DS8Counts
, 1-(Sum(DS8Counts)*1./ SUM(Total)) as DS8ChurnPCT
,Sum(DS8Counts)*1./ SUM(Total) as DS8RetentionPCT
--DS9
,SUM(DS9Counts)DS9Counts
, 1-(Sum(DS9Counts)*1./ SUM(Total)) as DS9ChurnPCT
,Sum(DS9Counts)*1./ SUM(Total) as DS9RetentionPCT
--DS10
,SUM(DS10Counts)DS10Counts
, 1-(Sum(DS10Counts)*1./ SUM(Total)) as DS10ChurnPCT
,Sum(DS10Counts)*1./ SUM(Total) as DS10RetentionPCT
--DS11
,SUM(DS11Counts)DS11Counts
, 1-(Sum(DS11Counts)*1./ SUM(Total)) as DS11ChurnPCT
,Sum(DS11Counts)*1./ SUM(Total) as DS11RetentionPCT
--DS12
,SUM(DS12Counts)DS12Counts
, 1-(Sum(DS12Counts)*1./ SUM(Total)) as DS12ChurnPCT
,Sum(DS12Counts)*1./ SUM(Total) as DS12RetentionPCT
--DS13
,SUM(DS13Counts)DS13Counts
, 1-(Sum(DS13Counts)*1./ SUM(Total)) as DS13ChurnPCT
,Sum(DS13Counts)*1./ SUM(Total) as DS13RetentionPCT
--DS14
,SUM(DS14Counts)DS14Counts
, 1-(Sum(DS14Counts)*1./ SUM(Total)) as DS14ChurnPCT
,Sum(DS14Counts)*1./ SUM(Total) as DS14RetentionPCT
--DS15
,SUM(DS15Counts)DS15Counts
, 1-(Sum(DS15Counts)*1./ SUM(Total)) as DS15ChurnPCT
,Sum(DS15Counts)*1./ SUM(Total) as DS15RetentionPCT
--DS16
,SUM(DS16Counts)DS16Counts
, 1-(Sum(DS16Counts)*1./ SUM(Total)) as DS16ChurnPCT
,Sum(DS16Counts)*1./ SUM(Total) as DS16RetentionPCT
--DS17
,SUM(DS17Counts)DS17Counts
, 1-(Sum(DS17Counts)*1./ SUM(Total)) as DS17ChurnPCT
,Sum(DS17Counts)*1./ SUM(Total) as DS17RetentionPCT
--DS18
,SUM(DS18Counts)DS18Counts
, 1-(Sum(DS18Counts)*1./ SUM(Total)) as DS18ChurnPCT
,Sum(DS18Counts)*1./ SUM(Total) as DS18RetentionPCT
--DS19
,SUM(DS19Counts)DS19Counts
, 1-(Sum(DS19Counts)*1./ SUM(Total)) as DS19ChurnPCT
,Sum(DS19Counts)*1./ SUM(Total) as DS19RetentionPCT
--DS20
,SUM(DS20Counts)DS20Counts
, 1-(Sum(DS20Counts)*1./ SUM(Total)) as DS20ChurnPCT
,Sum(DS20Counts)*1./ SUM(Total) as DS20RetentionPCT
--DS21
,SUM(DS21Counts)DS21Counts
, 1-(Sum(DS21Counts)*1./ SUM(Total)) as DS21ChurnPCT
,Sum(DS21Counts)*1./ SUM(Total) as DS21RetentionPCT
--DS22
,SUM(DS22Counts)DS22Counts
, 1-(Sum(DS22Counts)*1./ SUM(Total)) as DS22ChurnPCT
,Sum(DS22Counts)*1./ SUM(Total) as DS22RetentionPCT
--DS23
,SUM(DS23Counts)DS23Counts
, 1-(Sum(DS23Counts)*1./ SUM(Total)) as DS23ChurnPCT
,Sum(DS23Counts)*1./ SUM(Total) as DS23RetentionPCT
--DS24
,SUM(DS24Counts)DS24Counts
, 1-(Sum(DS24Counts)*1./ SUM(Total)) as DS24ChurnPCT
,Sum(DS24Counts)*1./ SUM(Total) as DS24RetentionPCT
 from Archive.VW_TGCPLus_DS
--where MinDSDate = '2016-08-01'
group by MinDSDate


GO
