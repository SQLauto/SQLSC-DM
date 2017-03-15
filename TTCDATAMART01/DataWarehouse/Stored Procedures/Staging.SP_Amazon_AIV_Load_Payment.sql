SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_Amazon_AIV_Load_Payment]
as
Begin

/* Only Inserting Values*/

 insert into Archive.Amazon_AIV_Payment (  [CountryCode] , [Partner] , [ReportDate] , [Format] ,  [PurchaseChannel] , [ReleaseDate] , [AvailableDate] ,[PurchaseDate] , [ContentType] ,[ASIN] , [VendorSku] , [CourseID] ,
    [CourseTitle] , [LectureNumber] , [LectureTitle] , [Unit] ,  [Revenue] )
 select  
  [CountryCode] , [Partner] , [ReportDate] , [Format] ,  [PurchaseChannel] , [ReleaseDate] , [AvailableDate] ,[PurchaseDate] , [ContentType] ,[ASIN] , [VendorSku] , [CourseID] ,
    [CourseTitle] , [LectureNumber] , [LectureTitle] , [Unit] ,  [Revenue]  
 from staging.Amazon_ssis_AIV

 
End
GO
