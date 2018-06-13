SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[TooManyMailings_Cleanup]

as 


   Insert into [DataWarehouse].[Staging].[Customer_TooMany_Mailings_Historical] 
   SELECT CustomerID ,DateAddedByAgent FROM [DataWarehouse].[Staging].[Customer_TooMany_Mailings] where customerid is not null


truncate table [DataWarehouse].[Staging].[Customer_TooMany_Mailings]
GO
