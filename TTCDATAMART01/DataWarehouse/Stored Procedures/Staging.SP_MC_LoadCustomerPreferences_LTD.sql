SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [Staging].[SP_MC_LoadCustomerPreferences_LTD]  
 @AsOfDate datetime = null  
   
/* -- 8/20/2014 -- PR -- Update demographics from WD table  */  
  
as  
begin  
 set nocount on  
   
    set @AsOfDate = coalesce(@AsOfDate, getdate())  
      
   exec Staging.SP_MC_LoadAllOrdersTGCPref_LTD @AsOfDate

      
    truncate table Staging.MC_CustomerPreference_LTD_TEMP  
      
    print 'load temp table'  
         
	
 insert into Staging.MC_CustomerPreference_LTD_TEMP  
 (  CustomerID,
	AsOfDate,   
    SubjectCatLTD,  
    SubjectPrefLTD,  
    SecondarySubjPrefLTD,   
	FormatMediaCatLTD,    
	FormatMediaPrefLTD, 
	FormatMediaLstLTD,
    --FormatAVCatLTD,  
    FormatAVPrefLTD,  
    FormatAVLstLTD,  
    --FormatPDCatLTD,    
    FormatPDPrefLTD, 
    FormatPDLstLTD,  
    OrderSourceCatLTD,
    OrderSourcePrefLTD,
    OrderSourceLstLTD,
	MD_ChannelRUCatLTD,
	MD_ChannelRUPrefLTD,
	MD_ChannelRULstLTD)  
    select distinct   
		oi.CustomerID,
		 @AsOfDate,   
		'X' as SubjectCatLTD,
		'X' as SubjectPrefLTD,
		'SCI' as SecondarySubjPrefLTD,
		'X' as FormatMediaCatLTD,
		'X' as FormatMediaPrefLTD,
		'q) 0: None' as FormatMediaLstLTD,
		--'X' as FormatAVCatLTD,
		'X' as FormatAVPrefLTD,
		'None' as FormatAVLstLTD,
		--'X' as FormatPDCatLTD,
		'X' as FormatPDPrefLTD,
		'p) 0: None' as FormatPDLstLTD,
		'X' as OrderSourceCatLTD,
		'X' as OrderSourcePrefLTD,
		't) 0: None' as OrderSourceLstLTD,
		'X' as MD_ChannelRUCatLTD,
		'X' as MD_ChannelRUPrefLTD,
		't) 0: None' as MD_ChannelRULstLTD
 FROM Staging.ValidPurchaseOrderItemsIgnoreReturns OI (nolock)  
 WHERE oi.DateOrdered < @AsOfDate   
       and oi.FormatMedia <> 'T'  
          
  --- Begin  update SubjectCatLTD
  
 /* To update SubjectCatLTD*/  
 /* If they have multiple subjects in LTD, then M else X*/  
   
    print 'update SubjectCatLTD'  
      
 UPDATE TCD  
 SET SubjectCatLTD = 'M'  
 FROM Staging.MC_CustomerPreference_LTD_TEMP  TCD   
    JOIN  
 (  
     select CustomerID  
  from Staging.MC_AllOrdersTGCPref_LTD csp (nolock)  
  group by CustomerID  
  having count(distinct SubjectCategory2) > 1  
 ) B on TCD.CustomerID = B.CustomerID          
      
 update cr  
 set cr.SubjectCatLTD = case when cr.SubjectCatLTD = 'X'  then sp.SubjectCategory2   else cr.SubjectCatLTD end
	,cr.SubjectPrefLTD = sp.SubjectCategory2
    from Staging.MC_CustomerPreference_LTD_TEMP cr  
    join   
    (  
  select   
   CustomerID,   
      SubjectCategory2,   
   rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc) as CategoryNum  
  from Staging.vw_MC_CustomerSubjectCategory2Preferences_LTD (nolock)  
 ) sp on sp.CustomerID = cr.CustomerID  
 where sp.CategoryNum = 1  
  
        
    print 'update Secondary subject pref'    
 update cr  
 set cr.SubjectCatLTD = case when cr.SubjectCatLTD = 'X' then sp.SubjectCategory2  else cr.SubjectCatLTD end
	,cr.SecondarySubjPrefLTD = sp.SubjectCategory2  
    from Staging.MC_CustomerPreference_LTD_TEMP cr  
    join   
    (select CustomerID,   
			SubjectCategory2,   
			rank() over (partition by CustomerID order by MaxParts desc, MaxDateOrdered desc, MaxOrderItemID desc) as CategoryNum  
	  from Staging.vw_MC_CustomerSubjectCategory2Preferences_LTD (nolock) ) sp on sp.CustomerID = cr.CustomerID  
	 where sp.CategoryNum = 2  
  
          
 update cr  
 set cr.SecondarySubjPrefLTD =   
     case when cr.SubjectCatLTD = 'FA' then 'MSC'  
		   when cr.SubjectCatLTD = 'MSC' then 'MTH'  
		   when cr.SubjectCatLTD = 'SCI' then 'EC'              
		   when cr.SubjectCatLTD = 'AH' then 'MH'  
		   when cr.SubjectCatLTD in ('EC','HS','MTH', 'PR', 'FW') then 'SCI'  
		   when cr.SubjectCatLTD in ('RL','LIT','MH', 'VA') then 'AH'  
		   when cr.SubjectCatLTD = 'PH' then 'LIT'  
		   else 'SCI'  
		  end  
 From Staging.MC_CustomerPreference_LTD_TEMP cr   
    where cr.SecondarySubjPrefLTD = cr.SubjectPrefLTD  
	/* End Subject cat calculations*/         
 
              
 /* Begin Format Media calculations*/   
   
    print 'Format Media Calculations'  
 UPDATE Staging.MC_CustomerPreference_LTD_TEMP   
 SET FormatMediaCatLTD = 'M'   
 WHERE CustomerID IN   
    (select CustomerID
	  from Staging.MC_AllOrdersTGCPref_LTD csp (nolock)  
	  group by CustomerID  
	  having count(distinct FormatMedia) > 1 )  
  
 --UPDATE TCD  
 --SET FormatMediaCatLTD = 'HM'  
 --FROM Staging.MC_CustomerPreference_LTD_TEMP TCD  
 --   join Staging.FN_MC_GetCustomerFormatMedia(@AsOfDate) fm on fm.CustomerID = tcd.CustomerID  
 --WHERE    
 --    TCD.FormatMediaCatLTD = 'M'   
 --       AND FM.FormatMedia = 'H'  
      
      
    print 'update format media Cat and Pref'  
 update cd  
 set cd.FormatMediaCatLTD = case when cd.FormatMediaCatLTD = 'X'  then cp.FormatMedia  else cd.FormatMediaCatLTD end
	,cd.FormatMediaPrefLTD = cp.FormatMedia  
    from Staging.MC_CustomerPreference_LTD_TEMP cd  
    join Staging.vw_MC_CustomerFormatMediaPreferences_LTD cp (nolock) on cp.CustomerID = cd.CustomerID  
 where cp.RankNum = 1  
		/* End Order Format Media calculations*/   

		/* Begin Order FormatAV calculations*/  
   
		print 'FormatAV calculations'  
	 --UPDATE Staging.MC_CustomerPreference_LTD_TEMP  
	 --SET FormatAVCatLTD = 'M'   
	 --WHERE CustomerID IN   
		--(  
		-- SELECT CustomerID   
		--	FROM Staging.FN_MC_GetCustomerFormatAV(@AsOfDate)  
	 -- GROUP BY CustomerID  
	 -- HAVING COUNT(CustomerID) > 1  
	 --)  
      
	 --UPDATE TCD  
	 --SET FormatAVCatLTD = 'HM'  
	 --FROM Staging.MC_CustomerPreference_LTD_TEMP TCD  
		--join Staging.FN_MC_GetCustomerFormatAV(@AsOfDate) fm on fm.CustomerID = tcd.CustomerID  
	 --WHERE   
		-- TCD.FormatAVCatLTD = 'M' AND  
	 -- FM.FormatAV = 'HS'  
          
	 --   update cd  
	 --set cd.FormatAVCatLTD = case when cd.FormatAVCatLTD = 'X'  then cp.FormatAV else cd.FormatAVCatLTD end 
		--	,cd.FormatAVPrefLTD = cp.FormatAV  
		--from Staging.MC_CustomerPreference_LTD_TEMP cd  
		--join Staging.vw_MC_CustomerFormatAVPreferences (nolock) cp on cp.CustomerID = cd.CustomerID  
	 --where   
		-- cp.RankNum = 1  

	 update cd  
	 set cd.FormatAVPrefLTD = cp.FormatAV  
		from Staging.MC_CustomerPreference_LTD_TEMP cd  
		join Staging.vw_MC_CustomerFormatAVPreferences_LTD (nolock) cp on cp.CustomerID = cd.CustomerID  
	 where cp.RankNum = 1
	 
	/* End Order FormatAV calculations*/  
      
	/* Begin Order FormatPD calculations*/     
   
			--print 'FormatPD calculations'  
		 --UPDATE Staging.MC_CustomerPreference_LTD_TEMP  
		 --SET FormatPDCatLTD = 'M'   
		 --WHERE CustomerID IN   
			--(  
			-- SELECT CustomerID   
			--	FROM Staging.FN_MC_GetCustomerFormatPD(@AsOfDate)  
		 -- GROUP BY CustomerID  
		 -- HAVING COUNT(CustomerID) > 1  
		 --)  
      
		 --UPDATE TCD  
		 --SET FormatPDCatLTD = 'HM'  
		 --FROM Staging.MC_CustomerPreference_LTD_TEMP TCD  
			--join Staging.FN_MC_GetCustomerFormatPD(@AsOfDate) fm on fm.CustomerID = tcd.CustomerID  
		 --WHERE   
			-- TCD.FormatPDCatLTD = 'M' AND  
		 -- FM.FormatPD = 'HS'  
      
		 update cd  
		 set cd.FormatPDPrefLTD = cp.FormatPD
			from Staging.MC_CustomerPreference_LTD_TEMP cd  
			join Staging.vw_MC_CustomerFormatPDPreferences_LTD cp (nolock) on cp.CustomerID = cd.CustomerID  
		 where cp.RankNum = 1  
	/* End Order FormatPD calculations*/     
		

      
 /* Begin Order OrderSource preference calculations*/     
   
    print 'Update OrderSource Pref'      
 UPDATE Staging.MC_CustomerPreference_LTD_TEMP  
 SET OrderSourceCatLTD = 'M'   
 WHERE CustomerID IN  (select CustomerID
					  from Staging.MC_AllOrdersTGCPref_LTD csp (nolock)  
					  group by CustomerID  
					  having count(distinct OrderSource) > 1 )   
          
 update cd  
 set cd.OrderSourceCatLTD = case when cd.OrderSourceCatLTD = 'X' then sp.OrderSource  else cd.OrderSourceCatLTD end
	,cd.OrderSourcePrefLTD = sp.OrderSource  
    from Staging.MC_CustomerPreference_LTD_TEMP cd  
    join Staging.vw_MC_CustomerOrderSourcePreferences_LTD sp (nolock) on sp.CustomerID = cd.CustomerID  
 where  sp.RankNum = 1  
 /* End Order OrderSource preference calculations*/     
      
              
 /* Begin Order channel preference calculations*/    
 
    print 'Update Channel Pref'      
 UPDATE Staging.MC_CustomerPreference_LTD_TEMP  
 SET MD_ChannelRUCatLTD = 'M'   
 WHERE CustomerID IN  (select CustomerID
					  from Staging.MC_AllOrdersTGCPref_LTD csp (nolock)  
					  group by CustomerID  
					  having count(distinct MD_ChannelRU) > 1 )   
          
 update cd  
 set cd.MD_ChannelRUCatLTD = case when cd.MD_ChannelRUCatLTD = 'X' then sp.MD_ChannelRU  
									else cd.MD_ChannelRUCatLTD
								end,    
		cd.MD_ChannelRUPrefLTD = sp.MD_ChannelRU  
    from Staging.MC_CustomerPreference_LTD_TEMP cd  
    join Staging.vw_MC_CustomerChannelRUPreferences_LTD sp (nolock) on sp.CustomerID = cd.CustomerID  
 where sp.RankNum = 1  
/* End Order channel preference calculations*/      
 
 
 /* Begin updates for the List or combo variables */		      
	update cd
	set cd.FormatMediaLstLTD = 
			 case when b.DVD = 0 and b.CD = 0 and b.DigitalAudio = 0 and b.DigitalVideo = 0 and (b.AudioTape + b.VideoTape) > 0 then 'p) 4: Other'
					when b.DVD = 0 and b.CD = 0 and b.DigitalAudio = 0 and b.DigitalVideo = 1 then 'b) 2: Digital Video'
					when b.DVD = 0 and b.CD = 0 and b.DigitalAudio = 1 and b.DigitalVideo = 0 then 'd) 4: Digital Audio'
					when b.DVD = 0 and b.CD = 0 and b.DigitalAudio = 1 and b.DigitalVideo = 1 then 'i) 24: Digital Audio/Digital Video'
					when b.DVD = 0 and b.CD = 1 and b.DigitalAudio = 0 and b.DigitalVideo = 0 then 'c) 3: CD'
					when b.DVD = 0 and b.CD = 1 and b.DigitalAudio = 0 and b.DigitalVideo = 1 then 'h) 23: CD/Digital Video'
					when b.DVD = 0 and b.CD = 1 and b.DigitalAudio = 1 and b.DigitalVideo = 0 then 'j) 34: CD/Digital Audio'
					when b.DVD = 0 and b.CD = 1 and b.DigitalAudio = 1 and b.DigitalVideo = 1 then 'n) 234: CD/Digital Audio/Digital Video'
					when b.DVD = 1 and b.CD = 0 and b.DigitalAudio = 0 and b.DigitalVideo = 0 then 'a) 1: DVD'
					when b.DVD = 1 and b.CD = 0 and b.DigitalAudio = 0 and b.DigitalVideo = 1 then 'e) 12: DVD/Digital Video'
					when b.DVD = 1 and b.CD = 0 and b.DigitalAudio = 1 and b.DigitalVideo = 0 then 'g) 14: DVD/Digital Audio'
					when b.DVD = 1 and b.CD = 0 and b.DigitalAudio = 1 and b.DigitalVideo = 1 then 'l) 124: DVD/Digital Audio/Digital Video'
					when b.DVD = 1 and b.CD = 1 and b.DigitalAudio = 0 and b.DigitalVideo = 0 then 'f) 13: DVD/CD'
					when b.DVD = 1 and b.CD = 1 and b.DigitalAudio = 0 and b.DigitalVideo = 1 then 'k) 123: DVD/Digital Video/CD'
					when b.DVD = 1 and b.CD = 1 and b.DigitalAudio = 1 and b.DigitalVideo = 0 then 'm) 134: DVD/Digital Audio/CD'
					when b.DVD = 1 and b.CD = 1 and b.DigitalAudio = 1 and b.DigitalVideo = 1 then 'o) 1234: All'
					else 'q) 0: None'
					end,
		cd.FormatAVLstLTD = case when (b.DVD + b.DigitalVideo + b.VideoTape) > 0 and (b.CD + b.DigitalAudio + b.AudioTape) = 0 then 'b) 2: Video'
									when (b.DVD + b.DigitalVideo + b.VideoTape) = 0 and (b.CD + b.DigitalAudio + b.AudioTape) > 0 then 'a) 1: Audio'
									when (b.DVD + b.DigitalVideo + b.VideoTape) > 0 and (b.CD + b.DigitalAudio + b.AudioTape) > 0 then 'c) 3: Both'
									else 'd) 4: None'
								end,
		cd.FormatPDLstLTD = case when (b.DVD + b.CD + b.VideoTape + b.AudioTape) > 0 and (b.DigitalVideo + b.DigitalAudio) = 0 then 'b) 2: Physical'
									when (b.DVD + b.CD + b.VideoTape + b.AudioTape) = 0 and (b.DigitalVideo + b.DigitalAudio) > 0 then 'a) 1: Digital'
									when (b.DVD + b.CD + b.VideoTape + b.AudioTape) > 0 and (b.DigitalVideo + b.DigitalAudio) > 0 then 'c) 3: Both'
									else 'd) 4: None'
								end,
		cd.OrderSourceLstLTD = case when b.WebOS = 1 and b.PhoneOS = 0 and b.MailOS = 0 and b.EMailOS = 0 and b.OtherOS = 0 then 'b) 2: Web'
										when b.WebOS = 1 and b.PhoneOS = 0 and b.MailOS = 0 and b.EMailOS = 0 and b.OtherOS = 1 then 'l) 25: Web/Other'
										when b.WebOS = 1 and b.PhoneOS = 0 and b.MailOS = 0 and b.EMailOS = 1 and b.OtherOS = 0 then 'k) 24: Web/Email'
										when b.WebOS = 1 and b.PhoneOS = 0 and b.MailOS = 0 and b.EMailOS = 1 and b.OtherOS = 1 then 'x) 245: Web/Email/Other'
										when b.WebOS = 1 and b.PhoneOS = 0 and b.MailOS = 1 and b.EMailOS = 0 and b.OtherOS = 0 then 'j) 23: Web/Mail'
										when b.WebOS = 1 and b.PhoneOS = 0 and b.MailOS = 1 and b.EMailOS = 0 and b.OtherOS = 1 then 'w) 235: Web/Mail/Other'
										when b.WebOS = 1 and b.PhoneOS = 0 and b.MailOS = 1 and b.EMailOS = 1 and b.OtherOS = 0 then 'v)  234: Web/Mail/Email'
										when b.WebOS = 1 and b.PhoneOS = 0 and b.MailOS = 1 and b.EMailOS = 1 and b.OtherOS = 1 then 'y) Multiple Source'
										when b.WebOS = 1 and b.PhoneOS = 1 and b.MailOS = 0 and b.EMailOS = 0 and b.OtherOS = 0 then 'f) 12: Phone/Web'
										when b.WebOS = 1 and b.PhoneOS = 1 and b.MailOS = 0 and b.EMailOS = 0 and b.OtherOS = 1 then 'r)  125: Phone/Web/Other'
										when b.WebOS = 1 and b.PhoneOS = 1 and b.MailOS = 0 and b.EMailOS = 1 and b.OtherOS = 0 then 'q)  124: Phone/Web/Email'
										when b.WebOS = 1 and b.PhoneOS = 1 and b.MailOS = 0 and b.EMailOS = 1 and b.OtherOS = 1 then 'y) Multiple Source'
										when b.WebOS = 1 and b.PhoneOS = 1 and b.MailOS = 1 and b.EMailOS = 0 and b.OtherOS = 0 then 'p) 123: Phone/Web/Mail'
										when b.WebOS = 1 and b.PhoneOS = 1 and b.MailOS = 1 and b.EMailOS = 0 and b.OtherOS = 1 then 'y) Multiple Source'
										when b.WebOS = 1 and b.PhoneOS = 1 and b.MailOS = 1 and b.EMailOS = 1 and b.OtherOS = 0 then 'y) Multiple Source'
										when b.WebOS = 1 and b.PhoneOS = 1 and b.MailOS = 1 and b.EMailOS = 1 and b.OtherOS = 1 then 'y) Multiple Source'
										when b.WebOS = 0 and b.PhoneOS = 0 and b.MailOS = 0 and b.EMailOS = 0 and b.OtherOS = 0 then 'z) 0: None'
										when b.WebOS = 0 and b.PhoneOS = 0 and b.MailOS = 0 and b.EMailOS = 0 and b.OtherOS = 1 then 'e) 5: Other'
										when b.WebOS = 0 and b.PhoneOS = 0 and b.MailOS = 0 and b.EMailOS = 1 and b.OtherOS = 0 then 'd) 4: Email'
										when b.WebOS = 0 and b.PhoneOS = 0 and b.MailOS = 0 and b.EMailOS = 1 and b.OtherOS = 1 then 'o) 45: Email/Other'
										when b.WebOS = 0 and b.PhoneOS = 0 and b.MailOS = 1 and b.EMailOS = 0 and b.OtherOS = 0 then 'c) 3: Mail'
										when b.WebOS = 0 and b.PhoneOS = 0 and b.MailOS = 1 and b.EMailOS = 0 and b.OtherOS = 1 then 'n) 35: Mail/Other'
										when b.WebOS = 0 and b.PhoneOS = 0 and b.MailOS = 1 and b.EMailOS = 1 and b.OtherOS = 0 then 'm) 34: Mail/Email'
										when b.WebOS = 0 and b.PhoneOS = 0 and b.MailOS = 1 and b.EMailOS = 1 and b.OtherOS = 1 then 'y) 345: Mail/Email/Other'
										when b.WebOS = 0 and b.PhoneOS = 1 and b.MailOS = 0 and b.EMailOS = 0 and b.OtherOS = 0 then 'a) 1: Phone'
										when b.WebOS = 0 and b.PhoneOS = 1 and b.MailOS = 0 and b.EMailOS = 0 and b.OtherOS = 1 then 'i) 15: Phone/Other'
										when b.WebOS = 0 and b.PhoneOS = 1 and b.MailOS = 0 and b.EMailOS = 1 and b.OtherOS = 0 then 'h) 14: Phone/Email'
										when b.WebOS = 0 and b.PhoneOS = 1 and b.MailOS = 0 and b.EMailOS = 1 and b.OtherOS = 1 then 'u) 145: Phone/Email/Other'
										when b.WebOS = 0 and b.PhoneOS = 1 and b.MailOS = 1 and b.EMailOS = 0 and b.OtherOS = 0 then 'g) 13: Phone/Mail'
										when b.WebOS = 0 and b.PhoneOS = 1 and b.MailOS = 1 and b.EMailOS = 0 and b.OtherOS = 1 then 't) 135: Phone/Mail/Other'
										when b.WebOS = 0 and b.PhoneOS = 1 and b.MailOS = 1 and b.EMailOS = 1 and b.OtherOS = 0 then 's) 134: Phone/Mail/Email'
										when b.WebOS = 0 and b.PhoneOS = 1 and b.MailOS = 1 and b.EMailOS = 1 and b.OtherOS = 1 then 'y) Multiple Source'
										else 'z) 0: None'
									end,
		cd.MD_ChannelRULstLTD = case when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'zz) 0: None'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'f) 6: Other'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'e) 5: WebDflt'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'u) 56: WebDflt/Other'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'd) 4: Email'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 't) 46: Email/Other'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 's) 45: Email/WebDflt'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z15) 456: Email/WebDflt/Other'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'c) 3: DgtlMkt'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'r) 36: DgtlMkt/Other'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'q) 35: DgtlMkt/WebDflt'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z14) 356: DgtlMkt/WebDflt/Other'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'p) 34: DgtlMkt/Email'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'z13) 346: DgtlMkt/Email/Other'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'z12) 345: DgtlMkt/Email/WebDflt'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'b) 2: SpaceAds'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'o) 26: SpaceAds/Other'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'n) 25: SpaceAds/WebDflt'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z11) 256: SpaceAds/WebDflt/Other'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'm) 24: SpaceAds/Email'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'z10) 246: SpaceAds/Email/Other'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'z9) 245: SpaceAds/Email/WebDflt'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'l) 23: SpaceAds/DgtlMkt'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'z8) 236: SpaceAds/DgtlMkt/Other'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'z7) 235: SpaceAds/DgtlMkt/WebDflt'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'z6) 234: SpaceAds/DgtlMkt/Email'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 0 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'a) 1: PhysclMail'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'k) 16: PhysclMail/Other'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'j) 15: PhysclMail/WebDflt'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z5) 156: PhysclMail/WebDflt/Other'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'i) 14: PhysclMail/Email'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'z4) 146: PhysclMail/Email/Other'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'z3) 145: PhysclMail/Email/WebDflt'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'h) 13: PhysclMail/DgtlMkt'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'z2) 136: PhysclMail/DgtlMkt/Other'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'z1) 135: PhysclMail/DgtlMkt/WebDflt'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'z) 134: PhysclMail/DgtlMkt/Email'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 0 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'g) 12: PhysclMail/SpaceAds'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'y) 126: PhysclMail/SpaceAds/Other'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'x) 125: PhysclMail/SpaceAds/WebDflt'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'w) 124: PhysclMail/SpaceAds/Email'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 0 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'v) 123: PhysclMail/SpaceAds/DgtlMkt'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 0 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 0 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 0 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 0 then 'z16) MultipleSource'
										when b.PhysclMail_ChnlRU = 1 and b.SpaceAds_ChnlRU = 1 and b.DgtlMrktng_ChnlRU = 1 and b.Email_ChnlRU = 1 and WebDefault_ChnlRU = 1 and b.Other_ChnlRU = 1 then 'z16) MultipleSource'
										else 'zz) 0: None'
									end
		-- select top 100 *
	from Staging.MC_CustomerPreference_LTD_TEMP cd  
    join (select CustomerID, 
			Convert(varchar,Max(Convert(int, DVD))) DVD, 
			Convert(varchar,Max(Convert(int, CD))) CD,
			Convert(varchar,Max(Convert(int, DigitalVideo))) DigitalVideo, 
			Convert(varchar,Max(Convert(int, DigitalAudio))) DigitalAudio,
			Convert(varchar,Max(Convert(int, VideoTape))) VideoTape, 
			Convert(varchar,Max(Convert(int, AudioTape))) AudioTape,
			Convert(varchar,Max(Convert(int, PhysclMail_ChnlRU))) PhysclMail_ChnlRU,
			Convert(varchar,Max(Convert(int, SpaceAds_ChnlRU))) SpaceAds_ChnlRU,
			Convert(varchar,Max(Convert(int, DgtlMrktng_ChnlRU))) DgtlMrktng_ChnlRU,
			Convert(varchar,Max(Convert(int, Email_ChnlRU))) Email_ChnlRU,
			Convert(varchar,Max(Convert(int, WebDefault_ChnlRU))) WebDefault_ChnlRU,
			Convert(varchar,Max(Convert(int, Other_ChnlRU))) Other_ChnlRU,
			Convert(varchar,Max(Convert(int, PhoneOS))) PhoneOS,
			Convert(varchar,Max(Convert(int, WebOS))) WebOS,
			Convert(varchar,Max(Convert(int, EmailOS))) EmailOS,
			Convert(varchar,Max(Convert(int, MailOS))) MailOS,
			Convert(varchar,Max(Convert(int, OtherOS))) OtherOS
		  from Staging.MC_AllOrdersTGCPref_LTD csp (nolock)  
		  group by CustomerID )b on cd.CustomerID = b.CustomerID
    /* End updates for the List or combo variables */		          
   
   -- if the data exists for the given asofdate, then delete
   --delete a
   --from Marketing.MC_CustomerPreference_LTD  a
   --where AsOfDate = @AsOfDate
  
	--insert into Marketing.MC_CustomerPreference_LTD  
    select * 
	into Marketing.MC_CustomerPreference_LTD  
	from Staging.MC_CustomerPreference_LTD_TEMP      
  
    truncate table Staging.MC_CustomerPreference_LTD_TEMP     
   
   
      
end  
GO
