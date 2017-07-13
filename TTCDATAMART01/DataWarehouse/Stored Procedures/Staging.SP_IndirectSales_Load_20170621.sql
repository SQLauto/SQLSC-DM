SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [Staging].[SP_IndirectSales_Load_20170621]
as
Begin

/* Only Inserting Values*/

 insert into Archive.Indirect_Sales (CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,Units,Revenue,PurchaseChannel )
 select CountryCode,PartnerName,ReportDate,Format,ReleaseDate,CourseID,LectureNumber,Units,Revenue,PurchaseChannel
 from  staging.Indirect_ssis_Sales
 where PartnerName is not null

End
GO
