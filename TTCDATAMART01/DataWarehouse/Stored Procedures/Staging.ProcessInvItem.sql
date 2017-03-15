SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Staging].[ProcessInvItem]
as
begin
    set nocount on
  
    update i
    set i.CourseID = si.CourseID
    from Staging.InvItem i
    join Staging.StockItemsPreSuperStar si (nolock) on i.StockItemID = si.UserStockItemID
    where 
        i.CourseID = 0
        and i.StockItemID like '[PD][AVCDM]%'


/* temp fix in place for course flags not setting up correctly from Intranet  9/9/2016 Vikram email from Preethi*/

             update DataWarehouse.Staging.InvItem
             set ForSaleonWeb = 1,
                    ForSaleToConsumer = 1
       where courseid in (select distinct courseid
                           from DataWarehouse.Mapping.dmcourse
                           where ReleaseDate between '6/1/2016' and getdate())

end
GO
