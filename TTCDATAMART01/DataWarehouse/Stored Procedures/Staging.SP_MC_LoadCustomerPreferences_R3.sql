SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Staging].[SP_MC_LoadCustomerPreferences_R3]  
 @AsOfDate datetime = null  
   
/* -- 8/20/2014 -- PR -- Update demographics from WD table  */  
  
as  
begin  
 set nocount on  
   
    set @AsOfDate = coalesce(@AsOfDate, getdate())  
      
    exec Staging.SP_MC_LoadMostRecentOrdersTGCPref @AsOfDate
      
    truncate table Staging.MC_CustomerPreference_R3_TEMP  
      
    print 'load temp table'  
          
	
 insert into Staging.MC_CustomerPreference_R3_TEMP  
 (  CustomerID,
	AsOfDate,   
    SubjectCatR3,  
    SubjectPrefR3,  
    SecondarySubjPrefR3,  
    FormatMediaCatR3,  
	FormatMediaPrefR3,
    FormatAVCatR3,  
    FormatAVPrefR3,  
    FormatPDCatR3,  
    FormatPDPrefR3,  
    OrderSourceCatR3,
    OrderSourcePrefR3,
	MD_ChannelRUPrefR3)  
    select distinct   
		oi.CustomerID,
		 @AsOfDate,   
        'X' SubjectCatR3,  
        'X' SubjectPrefR3,  
         'SCI' SecondarySubjPrefR3,  
        'X' FormatMediaCatR3,  
		'X' FormatMediaPrefR3,
        'X' FormatAVCatR3,  
        'X' FormatAVPrefR3,  
        'X' FormatPDCatR3,  
        'X' FormatPDPrefR3,  
        'X' OrderSourceCatR3,
        'X' OrderSourcePrefR3,
		'X' MD_ChannelRUPrefR3
 FROM Staging.ValidPurchaseOrderItemsIgnoreReturns OI (nolock)  
 WHERE oi.DateOrdered < @AsOfDate   
       and oi.FormatMedia <> 'T'  
          
  --- Begin  update SubjectCatR3
  
 /* To update SubjectCatR3*/  
 /* If they have multiple subjects in R3, then M else X*/  
   
    print 'update subjectcat3'  
      
 UPDATE TCD  
 SET SubjectCatR3 = 'M'  
 FROM Staging.MC_CustomerPreference_R3_TEMP  TCD   
    JOIN  
 (  
     select CustomerID  
  from Staging.MC_MostRecent3OrdersTGCPref csp (nolock)  
  group by CustomerID  
  having count(distinct SubjectCategory2) > 1  
 ) B on TCD.CustomerID = B.CustomerID          
      
 update cr  
 set cr.SubjectCatR3 = case when cr.SubjectCatR3 = 'X'  then sp.SubjectCategory2   else cr.SubjectCatR3 end
	,cr.SubjectPrefR3 = sp.SubjectCategory2
    from Staging.MC_CustomerPreference_R3_TEMP cr  
    join   
    (  
  select   
   CustomerID,   
      SubjectCategory2,   
   rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc) as CategoryNum  
  from Staging.vw_MC_CustomerSubjectCategory2Preferences (nolock)  
 ) sp on sp.CustomerID = cr.CustomerID  
 where sp.CategoryNum = 1  
  
 --update cr  
 --set  
 --   from Staging.MC_CustomerPreference_R3_TEMP cr  
 --   join   
 --   (  
 -- select   
 --  CustomerID,   
 --     SubjectCategory2,   
 --  rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc) as CategoryNum  
 -- from Staging.vw_MC_CustomerSubjectCategory2Preferences (nolock)  
 --) sp on sp.CustomerID = cr.CustomerID  
 --where   
 --    sp.CategoryNum = 1  
 --       and cr.SubjectCatR3 = 'X'  
        
        
    print 'update Secondary subject pref'    
 update cr  
 set cr.SubjectCatR3 = case when cr.SubjectCatR3 = 'X' then sp.SubjectCategory2  else cr.SubjectCatR3 end
	,cr.SecondarySubjPrefR3 = sp.SubjectCategory2  
    from Staging.MC_CustomerPreference_R3_TEMP cr  
    join   
    (  
  select   
   CustomerID,   
      SubjectCategory2,   
   rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc) as CategoryNum  
  from Staging.vw_MC_CustomerSubjectCategory2Preferences (nolock)  
 ) sp on sp.CustomerID = cr.CustomerID  
 where sp.CategoryNum = 2  
  
 --update cr  
 --set cr.SubjectCatR3 = sp.SubjectCategory2  
 --   from Staging.MC_CustomerPreference_R3_TEMP cr  
 --   join   
 --   (  
 -- select   
 --  CustomerID,   
 --     SubjectCategory2,   
 --  rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc) as CategoryNum  
 -- from Staging.vw_MC_CustomerSubjectCategory2Preferences (nolock)  
 --) sp on sp.CustomerID = cr.CustomerID  
 --where   
 --    sp.CategoryNum = 2  
 --       and cr.SubjectCatR3 = 'X'  
          
 update cr  
 set cr.SecondarySubjPrefR3 =   
     case   
         when cr.SubjectCatR3 = 'FA' then 'MSC'  
   when cr.SubjectCatR3 = 'MSC' then 'MTH'  
   when cr.SubjectCatR3 = 'SCI' then 'EC'              
   when cr.SubjectCatR3 = 'AH' then 'MH'  
   when cr.SubjectCatR3 in ('EC','HS','MTH', 'PR', 'FW') then 'SCI'  
   when cr.SubjectCatR3 in ('RL','LIT','MH', 'VA') then 'AH'  
   when cr.SubjectCatR3 = 'PH' then 'LIT'  
   else 'SCI'  
  end  
 From Staging.MC_CustomerPreference_R3_TEMP cr   
    where cr.SecondarySubjPrefR3 = cr.SubjectPrefR3  
      
 
              
 /* Format Media Calculations*/  
   
    print 'Format Media Calculations'  
 UPDATE Staging.MC_CustomerPreference_R3_TEMP   
 SET FormatMediaCatR3 = 'M'   
 WHERE CustomerID IN   
    (  
     SELECT CustomerID   
        FROM Staging.FN_MC_GetCustomerFormatMedia(@AsOfDate)  
  GROUP BY CustomerID  
  HAVING COUNT(CustomerID) > 1  
 )  
  
 UPDATE TCD  
 SET FormatMediaCatR3 = 'HM'  
 FROM Staging.MC_CustomerPreference_R3_TEMP TCD  
    join Staging.FN_MC_GetCustomerFormatMedia(@AsOfDate) fm on fm.CustomerID = tcd.CustomerID  
 WHERE    
     TCD.FormatMediaCatR3 = 'M'   
        AND FM.FormatMedia = 'H'  
      
      
    print 'update format media Cat and Pref'  
 update cd  
 set cd.FormatMediaCatR3 = case when cd.FormatMediaCatR3 = 'X'  then cp.FormatMedia  else cd.FormatMediaCatR3 end
	,cd.FormatMediaPrefR3 = cp.FormatMedia  
    from Staging.MC_CustomerPreference_R3_TEMP cd  
    join Staging.vw_MC_CustomerFormatMediaPreferences cp (nolock) on cp.CustomerID = cd.CustomerID  
 where   
     cp.RankNum = 1  
       -- and cd.FormatMediaCatR3 = 'X'  
          
          
 --   print 'Update format media pref'  
 --update cd  
 --set cd.FormatMediaPrefR3 = cp.FormatMedia  
 --   from Staging.MC_CustomerPreference_R3_TEMP cd  
 --   join Staging.vw_MC_CustomerFormatMediaPreferences cp (nolock) on cp.CustomerID = cd.CustomerID  
 --where   
 --    cp.RankNum = 1  
               
	 /* FormatAV Calculations */  
   
		print 'FormatAV calculations'  
	 UPDATE Staging.MC_CustomerPreference_R3_TEMP  
	 SET FormatAVCatR3 = 'M'   
	 WHERE CustomerID IN   
		(  
		 SELECT CustomerID   
			FROM Staging.FN_MC_GetCustomerFormatAV(@AsOfDate)  
	  GROUP BY CustomerID  
	  HAVING COUNT(CustomerID) > 1  
	 )  
      
	 UPDATE TCD  
	 SET FormatAVCatR3 = 'HM'  
	 FROM Staging.MC_CustomerPreference_R3_TEMP TCD  
		join Staging.FN_MC_GetCustomerFormatAV(@AsOfDate) fm on fm.CustomerID = tcd.CustomerID  
	 WHERE   
		 TCD.FormatAVCatR3 = 'M' AND  
	  FM.FormatAV = 'HS'  
          
	 --update cd  
	 --set cd.FormatAVCatR3 = cp.FormatAV  
		--from Staging.MC_CustomerPreference_R3_TEMP cd  
		--join Staging.vw_MC_CustomerFormatAVPreferences (nolock) cp on cp.CustomerID = cd.CustomerID  
	 --where   
		-- cp.RankNum = 1  
		--	and cd.FormatAVCatR3 = 'X'  
          
	 update cd  
	 set cd.FormatAVCatR3 = case when cd.FormatAVCatR3 = 'X'  then cp.FormatAV else cd.FormatAVCatR3 end 
			,cd.FormatAVPrefR3 = cp.FormatAV  
		from Staging.MC_CustomerPreference_R3_TEMP cd  
		join Staging.vw_MC_CustomerFormatAVPreferences (nolock) cp on cp.CustomerID = cd.CustomerID  
	 where   
		 cp.RankNum = 1  
      
		 /* FormatPD Calculations */  
   
			print 'FormatPD calculations'  
		 UPDATE Staging.MC_CustomerPreference_R3_TEMP  
		 SET FormatPDCatR3 = 'M'   
		 WHERE CustomerID IN   
			(  
			 SELECT CustomerID   
				FROM Staging.FN_MC_GetCustomerFormatPD(@AsOfDate)  
		  GROUP BY CustomerID  
		  HAVING COUNT(CustomerID) > 1  
		 )  
      
		 UPDATE TCD  
		 SET FormatPDCatR3 = 'HM'  
		 FROM Staging.MC_CustomerPreference_R3_TEMP TCD  
			join Staging.FN_MC_GetCustomerFormatPD(@AsOfDate) fm on fm.CustomerID = tcd.CustomerID  
		 WHERE   
			 TCD.FormatPDCatR3 = 'M' AND  
		  FM.FormatPD = 'HS'  
      
		 update cd  
		 set cd.FormatPDCatR3 = case when cd.FormatPDCatR3 = 'X' then cp.FormatPD  else cd.FormatPDCatR3 end
			,cd.FormatPDPrefR3 = cp.FormatPD
			from Staging.MC_CustomerPreference_R3_TEMP cd  
			join Staging.vw_MC_CustomerFormatPDPreferences cp (nolock) on cp.CustomerID = cd.CustomerID  
		 where   
			 cp.RankNum = 1  
				--and cd.FormatPDCatR3 = 'X'  
          
		 --update cd  
		 --set cd.FormatPDPrefR3 = cp.FormatPD  
			--from Staging.MC_CustomerPreference_R3_TEMP cd  
			--join Staging.vw_MC_CustomerFormatPDPreferences cp (nolock) on cp.CustomerID = cd.CustomerID  
		 --where   
			-- cp.RankNum = 1  
      
 -- <Order Source>      
   
    print 'Update OrderSource Pref'      
 UPDATE Staging.MC_CustomerPreference_R3_TEMP  
 SET OrderSourceCatR3 = 'MS'   
 WHERE CustomerID IN  
    (  
		SELECT CustomerID   
				FROM Staging.FN_MC_GetCustomerOrderSource(@AsOfDate)  
		  GROUP BY CustomerID  
		  HAVING COUNT(CustomerID) > 1   
    )    
          
 update cd  
 set cd.OrderSourceCatR3 = case when cd.OrderSourceCatR3 = 'X' then sp.OrderSource  else cd.OrderSourceCatR3 end
	,cd.OrderSourcePrefR3 = sp.OrderSource  
    from Staging.MC_CustomerPreference_R3_TEMP cd  
    join Staging.vw_MC_CustomerOrderSourcePreferences sp (nolock) on sp.CustomerID = cd.CustomerID  
 where   
     sp.RankNum = 1  
      
 --update cd  
 --set cd.OrderSourceCatR3 = sp.OrderSource  
 --   from Staging.MC_CustomerPreference_R3_TEMP cd  
 --   join Staging.vw_MC_CustomerOrderSourcePreferences sp (nolock) on sp.CustomerID = cd.CustomerID  
 --where   
 --    sp.RankNum = 1  
 --       and cd.OrderSourceCatR3 = 'X'  
 -- </Order Source>        
      
   

              
 /* Begin Order channel preference calculations*/        
 update cd  
 set cd.MD_ChannelRUPrefR3 = sp.MD_ChannelRU  
    from Staging.MC_CustomerPreference_R3_TEMP cd  
    join Staging.vw_MC_CustomerChannelRUPreferences sp (nolock) on sp.CustomerID = cd.CustomerID  
 where   
     sp.RankNum = 1  
/* End Order channel preference calculations*/      
         
   
   -- if the data exists for the given asofdate, then delete
   delete a
   from Marketing.MC_CustomerPreference_R3  a
   where AsOfDate = @AsOfDate
  
	insert into Marketing.MC_CustomerPreference_R3  
    select * 
	--into Marketing.MC_CustomerPreference_R3  
	from Staging.MC_CustomerPreference_R3_TEMP      
  
    truncate table Staging.MC_CustomerPreference_R3_TEMP     
   
   
   
      
end  
GO
