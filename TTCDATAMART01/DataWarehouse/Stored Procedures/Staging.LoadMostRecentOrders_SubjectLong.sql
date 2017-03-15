SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadMostRecentOrders_SubjectLong]  
@AsOfDate datetime = null
AS  
BEGIN  
 set nocount on  
    set @AsOfDate = isnull(@AsOfDate, getdate())      
      

    select   
        ccp.CustomerID,  
        ccp.OrderID,  
        ccp.DateOrdered,  
        oi.OrderItemID,  
        oi.CourseID,  
        oi.TotalParts,  
        oi.SubjectCategory,  
        oi.SubjectCategory2,  
        sc.SubjectPreferenceID,  
        ccp.OrderSource,  
        oi.FormatMedia,  
        oi.FormatAV,  
        oi.FormatAD,
        C.Subjectlong2 
        into #MROData
    from   
    (  
     select distinct    
            CustomerID,   
            OrderID,   
            DateOrdered,  
            OrderSource,  
   dense_rank() over (partition by po.CustomerID order by po.DateOrdered desc) as OrderRecencyRank           
     from Marketing.CompleteCoursePurchase po (nolock)  
     where po.DateOrdered < @AsOfDate  
    ) ccp  
--    join Staging.ValidPurchaseOrderItems oi (nolock) on ccp.OrderID = oi.OrderID -- NB! remove returns or not?  
    join Marketing.DMPurchaseOrderItems oi (nolock) on ccp.OrderID = oi.OrderID  
    left join Mapping.PCASubjectCategories sc (nolock) on sc.courseid = oi.CourseID  
    left join Staging.Vw_DMCourse C (nolock) on C.courseid = oi.CourseID  
    where   
     ccp.OrderRecencyRank <= 3  
        and oi.FormatMedia <> 'T'  
  
 
    begin  
	 truncate table Staging.MostRecent3Orders_SubjectLong  
     insert into Staging.MostRecent3Orders_SubjectLong  
     select * from #MROData (nolock)  
    end  
    
drop table #MROData 
end  


 
GO
