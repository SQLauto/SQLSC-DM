SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[LoadCustomerDynamicCourseRank]  
 @AsOfDate datetime = null  
   
/* -- 8/20/2014 -- PR -- Update demographics from WD table  */  
  
as  
begin  
 set nocount on  
   
    set @AsOfDate = coalesce(@AsOfDate, getdate())  
      
    exec Staging.LoadMostRecentOrders @AsOfDate, 'CDCR'  
      
    truncate table Staging.TempCustomerDynamicCourseRank  
      
    print 'load temp table'  
          
 insert into Staging.TempCustomerDynamicCourseRank  
 (  
     CustomerID,   
        Gender,  
        AsOfDate,   
        AsOfMonth,   
        AsOfYear,  
        CRComboID,  
        SubjectCatR3,  
        SubjectCat,  
        SubjectPref,  
        SecondarySubjPref,  
        FormatMediaCat,  
        FormatAVCat,  
        FormatADCat,  
        OrderSourceCat  
    )  
        select distinct   
     oi.CustomerID,   
  --isnull(left(cg.Gender,1), 'U') as Gender,  
  'U' as Gender,  
        @AsOfDate,   
  DATEPART(MM, @AsOfDate),   
        DATEPART(YY, @AsOfDate),  
        'X-X-00-01' CRComboID,  
        'X' SubjectCatR3,  
        'X' SubjectCat,  
        'X' SubjectPref,  
        'SCI' SecondarySubjPref,  
        'X' FormatMediaCat,  
        'X' FormatAVCat,  
        'X' FormatADCat,  
        'X' OrderSourceCat        
 FROM Staging.ValidPurchaseOrderItems OI (nolock)  
    -- left join Mapping.CustomerOverLay cg (nolock) on oi.CustomerID = cg.CustomerID  
   -- left join Mapping.CustomerOverlay_WD cg (nolock) on oi.CustomerID = cg.CustomerID -- 8/20/2014 -- PR -- Update demographics from WD table  
 WHERE   
     oi.DateOrdered < @AsOfDate   
        and oi.FormatMedia <> 'T'  
          
       
     update a  
     set a.Gender = isnull(left(cg.Gender,1),'U')  
 FROM Staging.TempCustomerDynamicCourseRank a (nolock)  
    -- left join Mapping.CustomerOverLay cg (nolock) on oi.CustomerID = cg.CustomerID  
   left join Mapping.CustomerOverlay_WD cg (nolock) on a.CustomerID = cg.CustomerID -- 8/20/2014 -- PR -- Update demographics from WD table  
        
          
    print 'update subjectcat'  
 UPDATE Staging.TempCustomerDynamicCourseRank   
 SET SubjectCat = 'M'  
 WHERE CustomerID IN (SELECT CustomerID FROM Staging.ValidPurchaseOrderItems poi (nolock)  
    GROUP BY CustomerID  
    HAVING COUNT(distinct poi.SubjectCategory2) > 1)  
  
 UPDATE  TCD  
 SET SubjectCat = 'HM'  
 FROM Staging.TempCustomerDynamicCourseRank TCD   
    JOIN Staging.ValidPurchaseOrderItems AFM ON TCD.CustomerID = AFM.CustomerID  
 WHERE   
     TCD.SubjectCat = 'M'   
  AND AFM.SubjectCategory2 = 'HS'  
  
 /* To update SubjectCatR3*/  
 /* If they have multiple subjects in R3, then M else X*/  
   
    print 'update subjectcat3'  
      
 UPDATE TCD  
 SET SubjectCatR3 = 'M'  
 FROM Staging.TempCustomerDynamicCourseRank  TCD   
    JOIN  
 (  
     select CustomerID  
  from Staging.MostRecent3OrdersCDCR csp (nolock)  
  group by CustomerID  
  having count(distinct SubjectCategory2) > 1  
 ) B on TCD.CustomerID = B.CustomerID          
      
 update cr  
 set cr.SubjectPref = sp.SubjectCategory2  
    from Staging.TempCustomerDynamicCourseRank cr  
    join   
    (  
  select   
   CustomerID,   
      SubjectCategory2,   
   rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc) as CategoryNum  
  from Staging.vwCustomerSubjectCategory2PreferencesCDCR (nolock)  
 ) sp on sp.CustomerID = cr.CustomerID  
 where sp.CategoryNum = 1  
  
 update cr  
 set cr.SubjectCat = sp.SubjectCategory2  
    from Staging.TempCustomerDynamicCourseRank cr  
    join   
    (  
  select   
   CustomerID,   
      SubjectCategory2,   
   rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc) as CategoryNum  
  from Staging.vwCustomerSubjectCategory2PreferencesCDCR (nolock)  
 ) sp on sp.CustomerID = cr.CustomerID  
 where   
     sp.CategoryNum = 1  
        and cr.SubjectCat = 'X'  
        
        
    print 'update Secondary subject pref'    
 update cr  
 set cr.SecondarySubjPref = sp.SubjectCategory2  
    from Staging.TempCustomerDynamicCourseRank cr  
    join   
    (  
  select   
   CustomerID,   
      SubjectCategory2,   
   rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc) as CategoryNum  
  from Staging.vwCustomerSubjectCategory2PreferencesCDCR (nolock)  
 ) sp on sp.CustomerID = cr.CustomerID  
 where sp.CategoryNum = 2  
  
 update cr  
 set cr.SubjectCat = sp.SubjectCategory2  
    from Staging.TempCustomerDynamicCourseRank cr  
    join   
    (  
  select   
   CustomerID,   
      SubjectCategory2,   
   rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc) as CategoryNum  
  from Staging.vwCustomerSubjectCategory2PreferencesCDCR (nolock)  
 ) sp on sp.CustomerID = cr.CustomerID  
 where   
     sp.CategoryNum = 2  
        and cr.SubjectCat = 'X'  
          
 update cr  
 set cr.SecondarySubjPref =   
     case   
         when cr.SubjectCat = 'FA' then 'MSC'  
   when cr.SubjectCat = 'MSC' then 'MTH'  
   when cr.SubjectCat = 'SCI' then 'EC'              
   when cr.SubjectCat = 'AH' then 'MH'  
   when cr.subjectcat in ('EC','HS','MTH', 'PR', 'FW') then 'SCI'  
   when cr.SubjectCat in ('RL','LIT','MH', 'VA') then 'AH'  
   when cr.SubjectCat = 'PH' then 'LIT'  
   else 'SCI'  
  end  
 From Staging.TempCustomerDynamicCourseRank cr   
    where cr.SecondarySubjPref = cr.SubjectPref  
      
 UPDATE TCD  
 SET LTDPurchases = T.SN,  
  LTDPurchasesBin = CASE WHEN ISNULL(T.SN,0) between 0 and 1 then '01-01'  
     WHEN T.SN between 2 and 3 then '02-03'   
     WHEN T.SN between 4 and 7 then '04-07'  
     WHEN T.SN between 8 and 18 then '08-18'  
     ELSE '19-10000'  
        END,  
  LTDPurchasesBinOffer =  CASE WHEN T.SN = 0 then '01-01'  
      WHEN T.SN = 1 then '02-03'  
      WHEN T.SN between 2 and 3 then '02-03'   
      WHEN T.SN between 4 and 7 then '04-07'  
      WHEN T.SN between 8 and 18 then '08-18'  
      ELSE '19-10000'  
     END,  
  DSLPurchase = DATEDIFF(DD, T.DO, @AsOfDate)                        
 FROM Staging.TempCustomerDynamicCourseRank TCD JOIN  
   (SELECT CustomerID, MAX(SequenceNum) AS SN, MAX(DateOrdered) As DO    
    FROM Marketing.DMPurchaseOrders   
    WHERE DateOrdered < @AsOfDate  
    GROUP BY CustomerID) T ON TCD.CustomerID = T.CustomerID  
       
       
    print 'update CRComboID'       
 UPDATE Staging.TempCustomerDynamicCourseRank  
 SET CRComboID = CONVERT(VARCHAR(50),REPLACE(REPLACE(ISNULL(SubjectPref,'X'),' ',''),'X','SCI')+'-'+  
   CASE WHEN REPLACE(ISNULL(Gender,'O'),' ','') IN ('F','M') THEN REPLACE(Gender,' ','')   
    ELSE 'O'  
   END+'-'+CASE WHEN ISNULL(LTDPurchases,0) = 0 then '01-01'  
     WHEN LTDPurchases = 1 then '02-03'  
     WHEN LTDPurchases between 2 and 3 then '02-03'   
     WHEN LTDPurchases between 4 and 7 then '04-07'  
     WHEN LTDPurchases between 8 and 18 then '08-18'  
     ELSE '19-10000'  
    END)  
  
 UPDATE Staging.TempCustomerDynamicCourseRank  
 SET CRComboIDOrig = CONVERT(VARCHAR(50),REPLACE(REPLACE(ISNULL(SubjectPref,'X'),' ',''),'X','SCI')+'-'+  
   CASE WHEN REPLACE(ISNULL(Gender,'O'),' ','') IN ('F','M') THEN REPLACE(Gender,' ','')   
    ELSE 'O'  
   END+'-'+CASE WHEN ISNULL(LTDPurchases,0) = 0 then '01-01'  
     WHEN LTDPurchases = 1 then '01-01'  
     WHEN LTDPurchases between 2 and 3 then '02-03'   
     WHEN LTDPurchases between 4 and 7 then '04-07'  
     WHEN LTDPurchases between 8 and 18 then '08-18'  
     ELSE '19-10000'  
    END)  
  
 -----------------------------------------------------------------  
 -- Load Num Of New Courses Purchased  
 -----------------------------------------------------------------  
 --DECLARE @AsOfDate DATETIME  
 --SET @AsOfDate = '04/01/2004'  
  
    print 'Load Num Of New Courses Purchased'  
 UPDATE TCD  
 SET LTDNewCoursesPur = T.CntNewCourse,  
  LTDNewCourseSales = T.TotalNewCourseSales,  -- PR -- Added new course sales information for cube (11/16/2007)  
  DSLNewCoursePur = DATEDIFF(DD, T.MaxDateOrdered, @AsOfDate)  
 FROM Staging.TempCustomerDynamicCourseRank TCD INNER JOIN  
 (SELECT CustomerID, COUNT(FlagNewCourse) As CntNewCourse, MAX(DateOrdered) As MaxDateOrdered,   
  SUM(TotalSales) AS TotalNewCourseSales -- PR -- Added new course sales information for cube (11/16/2007)  
  FROM Marketing.DMPurchaseOrderItems  
  WHERE  FlagNewCourse = 1 AND  
   DateOrdered < @AsOfDate AND  
   TotalSales BETWEEN 10 AND 1500 -- PR -- Added this to for new course sales information (11/16/2007)  
  GROUP BY CustomerID) T ON  
 TCD.CustomerID = T.CustomerID  
      
 UPDATE TCD  
 SET TCD.LTDPurchAmount = T.FS,  
  TCD.LTDAvgOrd = CONVERT(FLOAT, T.FS)/CONVERT(FLOAT, T.O)  
 FROM Staging.TempCustomerDynamicCourseRank TCD, (SELECT CustomerID, SUM(FinalSales) FS, COUNT(OrderID) O  
  FROM Marketing.DMPurchaseOrders   
  WHERE DateOrdered < @AsOfDate AND  
   FinalSales < 1500  
  GROUP BY CustomerID) T  
 WHERE TCD.CustomerID = T.CustomerID   
      
 --- Update TenureDays ------------  
 --DECLARE @AsOfDate DATETIME  
 --SET @AsOfDate = '02/01/2005'  
  
  
    print 'update tenure days'  
 UPDATE TCD  
  SET TenureDays = DATEDIFF(DD, DPO.DateOrdered, @AsOfDate)  
  FROM Staging.TempCustomerDynamicCourseRank TCD INNER JOIN Marketing.DMPurchaseOrders DPO   
   ON TCD.CustomerID = DPO.CustomerID AND  
   DPO.SequenceNum = 1  
              
 /* Format Media Calculations*/  
   
    print 'Format Media Calculations'  
 UPDATE Staging.TempCustomerDynamicCourseRank   
 SET FormatMediaCat = 'M'   
 WHERE CustomerID IN   
    (  
     SELECT CustomerID   
        FROM Staging.GetCustomerFormatMedia(@AsOfDate)  
  GROUP BY CustomerID  
  HAVING COUNT(CustomerID) > 1  
 )  
  
 UPDATE TCD  
 SET FormatMediaCat = 'HM'  
 FROM Staging.TempCustomerDynamicCourseRank TCD  
    join Staging.GetCustomerFormatMedia(@AsOfDate) fm on fm.CustomerID = tcd.CustomerID  
 WHERE    
     TCD.FormatMediaCat = 'M'   
        AND FM.FormatMedia = 'H'  
      
      
    print 'update format media'  
 update cd  
 set cd.FormatMediaCat = cp.FormatMedia  
    from Staging.TempCustomerDynamicCourseRank cd  
    join Staging.vwCustomerFormatMediaPreferences cp (nolock) on cp.CustomerID = cd.CustomerID  
 where   
     cp.RankNum = 1  
        and cd.FormatMediaCat = 'X'  
          
          
    print 'Update format media pref'  
 update cd  
 set cd.R3FormatMediaPref = cp.FormatMedia  
    from Staging.TempCustomerDynamicCourseRank cd  
    join Staging.vwCustomerFormatMediaPreferences cp (nolock) on cp.CustomerID = cd.CustomerID  
 where   
     cp.RankNum = 1  
               
 /* FormatAV Calculations */  
   
    print 'FormatAV calculations'  
 UPDATE Staging.TempCustomerDynamicCourseRank  
 SET FormatAVCat = 'M'   
 WHERE CustomerID IN   
    (  
     SELECT CustomerID   
        FROM Staging.GetCustomerFormatAV(@AsOfDate)  
  GROUP BY CustomerID  
  HAVING COUNT(CustomerID) > 1  
 )  
      
 UPDATE TCD  
 SET FormatAVCat = 'HM'  
 FROM Staging.TempCustomerDynamicCourseRank TCD  
    join Staging.GetCustomerFormatAV(@AsOfDate) fm on fm.CustomerID = tcd.CustomerID  
 WHERE   
     TCD.FormatAVCat = 'M' AND  
  FM.FormatAV = 'HS'  
          
 update cd  
 set cd.FormatAVCat = cp.FormatAV  
    from Staging.TempCustomerDynamicCourseRank cd  
    join Staging.vwCustomerFormatAVPreferences (nolock) cp on cp.CustomerID = cd.CustomerID  
 where   
     cp.RankNum = 1  
        and cd.FormatAVCat = 'X'  
          
 update cd  
 set cd.R3FormatAVPref = cp.FormatAV  
    from Staging.TempCustomerDynamicCourseRank cd  
    join Staging.vwCustomerFormatAVPreferences (nolock) cp on cp.CustomerID = cd.CustomerID  
 where   
     cp.RankNum = 1  
      
 /* FormatAD Calculations */  
   
    print 'formatAD calculations'  
 UPDATE Staging.TempCustomerDynamicCourseRank  
 SET FormatADCat = 'M'   
 WHERE CustomerID IN   
    (  
     SELECT CustomerID   
        FROM Staging.GetCustomerFormatAD(@AsOfDate)  
  GROUP BY CustomerID  
  HAVING COUNT(CustomerID) > 1  
 )  
      
 UPDATE TCD  
 SET FormatADCat = 'HM'  
 FROM Staging.TempCustomerDynamicCourseRank TCD  
    join Staging.GetCustomerFormatAD(@AsOfDate) fm on fm.CustomerID = tcd.CustomerID  
 WHERE   
     TCD.FormatADCat = 'M' AND  
  FM.FormatAD = 'HS'  
      
 update cd  
 set cd.FormatADCat = cp.FormatAD  
    from Staging.TempCustomerDynamicCourseRank cd  
    join Staging.vwCustomerFormatADPreferences cp (nolock) on cp.CustomerID = cd.CustomerID  
 where   
     cp.RankNum = 1  
        and cd.FormatADCat = 'X'  
          
 update cd  
 set cd.R3FormatADPref = cp.FormatAD  
    from Staging.TempCustomerDynamicCourseRank cd  
    join Staging.vwCustomerFormatADPreferences cp (nolock) on cp.CustomerID = cd.CustomerID  
 where   
     cp.RankNum = 1  
      
 -- <Order Source>      
   
    print 'Update OrderSource Pref'      
 UPDATE Staging.TempCustomerDynamicCourseRank  
 SET OrderSourceCat = 'MS'   
 WHERE CustomerID IN  
    (  
        SELECT CustomerID  
        FROM Staging.vwOrders (nolock)   
        GROUP BY CustomerID   
        HAVING COUNT(distinct OrderSource) > 1      
    )    
          
 update cd  
 set cd.R3OrderSourcePref = sp.OrderSource  
    from Staging.TempCustomerDynamicCourseRank cd  
    join Staging.vwCustomerOrderSourcePreferences sp (nolock) on sp.CustomerID = cd.CustomerID  
 where   
     sp.RankNum = 1  
      
 update cd  
 set cd.OrderSourceCat = sp.OrderSource  
    from Staging.TempCustomerDynamicCourseRank cd  
    join Staging.vwCustomerOrderSourcePreferences sp (nolock) on sp.CustomerID = cd.CustomerID  
 where   
     sp.RankNum = 1  
        and cd.OrderSourceCat = 'X'  
 -- </Order Source>        
      
    -- 5/25/12/SK: TTB   
      
    print 'Update TTB'           
    update Staging.TempCustomerDynamicCourseRank  
    set TTB =  
        case   
         when LTDPurchases = 1 then 0  
         when LTDPurchases > 1 and ((TenureDays - DSLPurchase)/30)/(LTDPurchases - 1) < 1 then 1  
         when LTDPurchases > 1 and ((TenureDays - DSLPurchase)/30)/(LTDPurchases - 1) >= 1 then ((TenureDays - DSLPurchase)/30)/(LTDPurchases - 1)  
        end;  
    update Staging.TempCustomerDynamicCourseRank          
 set TTB_Bin=  
        case   
         when TTB = 0 then 'ZZ: 0 Month'  
         when TTB between 1 and 6 then 'A: 1-6 Months'  
         when TTB between 7 and 12 then 'B: 7-12 Months'  
         when TTB between 13 and 18 then 'C: 13-18 Months'  
         when TTB between 19 and 24 then 'D: 19-24 Months'  
         when TTB > 24 then 'Z: 24+ Months'  
         else 'ZZ: 0 Month'                          
        end;  
  
 --if datepart(day, getdate()) = 1   
 --   begin -- If it is first of the month, then save the signature table  
 -- exec Staging.AddToMonthlyArchive 'CustomerDynamicCourseRank'  
 --   end        
 /* Create SnapShot*/
Declare @SQL nvarchar(1000), @Date Varchar(10) = CONVERT(varchar,  GETDATE(), 112)
If DATEPART(d,getdate()) = 1
Begin 
set @SQL = '
			if object_id (''archive.CustomerDynamicCourseRank'+ @Date + ''') is null
			select * into archive.CustomerDynamicCourseRank' + @Date + ' from Marketing.CustomerDynamicCourseRank'
exec (@SQL)
Print 'CustomerDynamicCourseRank Monthly Snapshot Table Created'
End      
  
  
    truncate table Marketing.CustomerDynamicCourseRank          
    insert into Marketing.CustomerDynamicCourseRank  
    select * from Staging.TempCustomerDynamicCourseRank      
    truncate table Staging.TempCustomerDynamicCourseRank     
   
   
   
      
end  
GO
