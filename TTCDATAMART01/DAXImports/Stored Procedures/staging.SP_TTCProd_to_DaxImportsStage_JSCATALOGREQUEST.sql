SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [staging].[SP_TTCProd_to_DaxImportsStage_JSCATALOGREQUEST]
as

/* This routine is used to export JSCATALOGREQUEST. 
Date Written: 2017-01-10 BondugulaV
Last Updated: 2017-01-10 BondugulaV Initial

*/


Begin

truncate table [staging].[JSCATALOGREQUEST]


Insert into [staging].[JSCATALOGREQUEST] 
select * 
from [TTCPROD2009]..[JSCATALOGREQUEST]

End




GO
