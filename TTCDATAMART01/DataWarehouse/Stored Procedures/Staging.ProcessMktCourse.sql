SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Staging].[ProcessMktCourse]
as
begin
    set nocount on
      
	insert into Staging.MktCourse 
    (
	    CourseID
	)
    select distinct 
    	si.CourseID 
    from Staging.StockItemsPreSuperStar si (nolock)
    left join Staging.MktCourse c (nolock) on c.CourseID = si.CourseID
    where 
    	c.CourseID is null
        and si.UserSTockItemID like '[PD][AVCDM]%' 

end
GO
