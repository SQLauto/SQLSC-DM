SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Mapping].[Vw_EPC_Priority]
as
select op.name OptionName,isnull(f.name,op.name)Priority, description + ISNULL(f.name,'')  Priority_description 
from DataWarehouse.Staging.epc_ssis_option Op
left join DataWarehouse.Staging.epc_ssis_frequency F 
on op.name = Op.name
and op.name = 'Exclusive Offers'

GO
