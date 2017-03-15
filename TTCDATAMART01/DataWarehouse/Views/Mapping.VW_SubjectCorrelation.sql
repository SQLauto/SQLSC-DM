SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE View [Mapping].[VW_SubjectCorrelation]
as
select CRSubjAbbr,PrimarySubjAbbr, Row_number () over( partition by CRSubjAbbr order by  SeqNum ) RNK
from DataWarehouse.Mapping.SubjectCorrelation
GO
