SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_TGC_Create_Rolling_SYNONYM] @Debug bit = 0
as
Begin
Declare @SQL Nvarchar(4000) , @Year int , @Prior1Year int, @Prior2Year int, @Prior3Year int, @Prior4Year int

set @Year = Year(Getdate())
set @Prior1Year = @Year-1
set @Prior2Year = @Year-2
set @Prior3Year = @Year-3
set @Prior4Year = @Year-4

 

select @Year as '@Year',@Prior1Year as '@Prior1Year' , @Prior2Year as '@Prior2Year' , @Prior3Year as '@Prior3Year' , @Prior4Year  as '@Prior4Year'

Set @SQL  =
'
Begin
		 DROP SYNONYM [Archive].[EmailhistoryCurrentYear]
		 CREATE SYNONYM [Archive].[EmailhistoryCurrentYear] FOR [DataWarehouse].[Archive].[EmailHistory'+ Cast(@Year as varchar(4)) + ']

		 DROP SYNONYM [Archive].[EmailhistoryPrior1Year]
		 CREATE SYNONYM [Archive].[EmailhistoryPrior1Year] FOR [DataWarehouse].[Archive].[EmailHistory'+ Cast(@Prior1Year as varchar(4)) + ']

		 DROP SYNONYM [Archive].[EmailhistoryPrior2Year]
		 CREATE SYNONYM [Archive].[EmailhistoryPrior2Year] FOR [DataWarehouse].[Archive].[EmailHistory'+ Cast(@Prior2Year as varchar(4)) + ']

		 DROP SYNONYM [Archive].[EmailhistoryPrior3Year]
		 CREATE SYNONYM [Archive].[EmailhistoryPrior3Year] FOR [DataWarehouse].[Archive].[EmailHistory'+ Cast(@Prior3Year as varchar(4)) + ']

		 DROP SYNONYM [Archive].[EmailhistoryPrior4Year]
		 CREATE SYNONYM [Archive].[EmailhistoryPrior4Year] FOR [DataWarehouse].[Archive].[EmailHistory'+ Cast(@Prior4Year as varchar(4)) + ']
 End

 Begin
		 DROP SYNONYM [Archive].[MailhistoryCurrentYear]
		 CREATE SYNONYM [Archive].[MailhistoryCurrentYear] FOR [DataWarehouse].[Archive].[MailingHistory'+ Cast(@Year as varchar(4)) + ']
 
		 DROP SYNONYM [Archive].[MailhistoryPrior1Year]
		 CREATE SYNONYM [Archive].[MailhistoryPrior1Year] FOR [DataWarehouse].[Archive].[MailingHistory'+ Cast(@Prior1Year as varchar(4)) + ']
 
		 DROP SYNONYM [Archive].[MailhistoryPrior2Year]
		 CREATE SYNONYM [Archive].[MailhistoryPrior2Year] FOR [DataWarehouse].[Archive].[MailingHistory'+ Cast(@Prior2Year as varchar(4)) + ']
  
  		 DROP SYNONYM [Archive].[MailhistoryPrior3Year]
		 CREATE SYNONYM [Archive].[MailhistoryPrior3Year] FOR [DataWarehouse].[Archive].[MailingHistory'+ Cast(@Prior3Year as varchar(4)) + ']
  
  		 DROP SYNONYM [Archive].[MailhistoryPrior4Year]
		 CREATE SYNONYM [Archive].[MailhistoryPrior4Year] FOR [DataWarehouse].[Archive].[MailingHistory'+ Cast(@Prior4Year as varchar(4)) + ']
 End
 
 '
 Print @SQL

 if @Debug = 0
	 Begin 
	 Exec (@SQL)
	 End
 End
  
 
GO
