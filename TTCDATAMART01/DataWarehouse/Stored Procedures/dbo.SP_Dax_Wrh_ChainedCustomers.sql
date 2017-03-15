SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[SP_Dax_Wrh_ChainedCustomers]
As

Begin

if OBJECT_ID('Datawarehouse.marketing.ChainedCustomers') is not null
drop table Datawarehouse.marketing.ChainedCustomers


select * into Datawarehouse.marketing.ChainedCustomers
from DAXImports..CustomerExport
where isnull(JSMERGEDROOT,'') <> ''



End
GO
