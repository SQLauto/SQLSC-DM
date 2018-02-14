SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [Archive].[Vw_TGC_DigitalConsumption]
AS

Select  S.Actiondate,S.CustomerID,S.MagentoUserID,S.MarketingCloudVisitorID,S.MobileDeviceType,S.MobileDevice,S.MediaName
,S.CourseID,S.LectureNumber,S.Action,S.TotalActions,S.FlagOnline,S.StreamedOrDownloadedFormatType
,S.MediaTimePlayed,S.Watched25pct,S.Watched50pct,S.Watched75pct,S.Watched95pct,S.MediaCompletes
,S.Lecture_duration,S.GeoSegmentationCountries,S.BrowserOrAppVersion,S.Platform,S.FormatPurchased,S.orderid,S.StockItemID,S.BillingCountryCode,S.DateOrdered,S.TransactionType
,b.CourseName,C.LectureName,b.PrimaryWebCategory,b.SubjectCategory2,b.PlusGenre, Case when S.CourseID is not null and b.PlusGenre is not null then 1 else 0 end CourseAvailableOnPlus
,S.DMLastUpdated
From Archive.Omni_TGC_Streaming S
Left join (select CourseID, CourseName, PrimaryWebCategory, SubjectCategory2, TGCPlusSubjectCategory as PlusGenre from staging.vw_dmcourse (nolock) where BundleFlag = 0 and Courseid > 0) b 
on S.CourseID = b.CourseID																								
Left Join (select distinct CourseID, LectureNum as LectureNumber, Title as LectureName from mapping.MagentoCourseLectureExport (nolock) where CourseID > 0) c 
on S.CourseID = c.CourseID and S.LectureNumber = c.LectureNumber	
 

Union ALL

Select  D.Actiondate,D.CustomerID,D.MagentoUserID,D.MarketingCloudVisitorID,D.MobileDeviceType,D.MobileDevice,D.MediaName
,D.CourseID,D.LectureNumber,D.Action,D.TotalActions,D.FlagOnline,D.StreamedOrDownloadedFormatType
,Null as MediaTimePlayed,Null as Watched25pct,Null as Watched50pct,Null as Watched75pct,Null as Watched95pct,Null as MediaCompletes
,D.Lecture_duration,D.GeoSegmentationCountries,D.BrowserOrAppVersion,D.Platform,D.FormatPurchased,D.orderid,D.StockItemID,D.BillingCountryCode,D.DateOrdered,D.TransactionType
,b.CourseName,C.LectureName,b.PrimaryWebCategory,b.SubjectCategory2,b.PlusGenre, Case when D.CourseID is not null and b.PlusGenre is not null then 1 else 0 end CourseAvailableOnPlus
,D.DMLastUpdated
From Archive.Omni_TGC_Downloads D
Left join (select CourseID, CourseName, PrimaryWebCategory, SubjectCategory2, TGCPlusSubjectCategory as PlusGenre from staging.vw_dmcourse (nolock) where BundleFlag = 0 and Courseid > 0) b 
on D.CourseID = b.CourseID																								
Left Join (select distinct CourseID, LectureNum as LectureNumber, Title as LectureName from mapping.MagentoCourseLectureExport (nolock) where CourseID > 0) c 
on D.CourseID = c.CourseID and D.LectureNumber = c.LectureNumber																								
 

/*
Select Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,FlagOnline,StreamedOrDownloadedFormatType
,MediaTimePlayed,Watched25pct,Watched50pct,Watched75pct,Watched95pct,MediaCompletes
,Lecture_duration,GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType,DMLastUpdated
From Archive.Omni_TGC_Streaming

Union All

Select Actiondate,CustomerID,MagentoUserID,MarketingCloudVisitorID,MobileDeviceType,MobileDevice,MediaName,CourseID,LectureNumber,Action,TotalActions,FlagOnline,StreamedOrDownloadedFormatType
,Null as MediaTimePlayed,Null as Watched25pct,Null as Watched50pct,Null as Watched75pct,Null as Watched95pct,Null as MediaCompletes
,Lecture_duration,GeoSegmentationCountries,BrowserOrAppVersion,Platform,FormatPurchased,orderid,StockItemID,BillingCountryCode,DateOrdered,TransactionType,DMLastUpdated
From Archive.Omni_TGC_Downloads
*/

GO
