SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Staging].[vw_EU_Countries]  
AS  
   Select *  
   from Mapping.TGCPlusCountry  
   where Alpha2Code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','GR','FR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','GB')  
  
GO
