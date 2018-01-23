SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Archive].[vw_TB_Indirect_LibraryDashboard] as
select 
CountryCode, PartnerName, ReportDate, Format, ReleaseDate, CourseID, LectureNumber, Units, Revenue, PurchaseChannel,
Library, State, PostalCode, ZipCode, CourseName, Title, TGC_ReleaseDate, SubjectCategory, SubjectCategory2, Topic, SubTopic, TGCPlusSubjectCategory,
PrimaryWebCategory, City, ZipCodeType, Population, DMlastupdated, county from archive.Vw_Tb_Indirect_Sales 
where PartnerName in ('Hoopla', 'OverDrive', 'Recorded Books LTD') and Library is not null
union all
Select
CountryCode, PartnerName, ReportDate, Format, ReleaseDate, CourseID, LectureNumber, sum(Units) Units, sum(Revenue) Revenue, PurchaseChannel,
Library, State, PostalCode, ZipCode, CourseName, Title, TGC_ReleaseDate, SubjectCategory, SubjectCategory2, Topic, SubTopic, TGCPlusSubjectCategory,
PrimaryWebCategory, City, ZipCodeType, Population, DMlastupdated, county
from
(
select  
Library.CountryCode, 'IndividualLibrarySales' as PartnerName, cast(a.DateOrdered as date) ReportDate, a.FormatMedia as Format, cast(CourseReleaseDate as date) ReleaseDate, a.CourseID, '' as LectureNumber, 
TotalQuantity as Units, TotalSales as Revenue, '' as PurchaseChannel, 
Library.Library, Library.State, Library.PostalCode, Library.ZipCode, a.CourseName, a.CourseName as Title, cast(a.CourseReleaseDate as date) TGC_ReleaseDate, a.SubjectCategory, a.SubjectCategory2, e.Topic as Topic, e.SubTopic as SubTopic, e.TGCPlusSubjectCategory as TGCPlusSubjectCategory,
e.PrimaryWebCategory as PrimaryWebCategory, Library.City, c.ZipCodeType, isnull(c.EstimatedPopulation,0) as Population, GETDATE() as DMLastUpdated, d.county
from marketing.DMPurchaseOrderItems (nolock) a
	join 
(
select CustomerID,  CountryCode, 
case	
	when CompanyName in ('') then Address1
	when CompanyName = '-' then Address1
	when CompanyName = '.' then Address1
	else CompanyName end as Library, State, PostalCode, left(PostalCode, 5) as ZipCode, City
from datawarehouse.Staging.vw_PublicLibraries (nolock) 
) Library on a.CustomerID = Library.CustomerID  
left join mapping.zipcodes (nolock) c on Library.ZipCode = c.ZipCode 
left join mapping.ZipCodes_CountyLkp (nolock) d on Library.ZipCode = d.Zipcode
left join (select CourseID, Topic, SubTopic, TGCPlusSubjectCategory, PrimaryWebCategory from staging.Vw_DMCourse (nolock) where BundleFlag = 0) e on a.CourseID = e.CourseID
) as Final
where Year(ReportDate) >= 2016 and Format in ('C','D','T')
group by
CountryCode, PartnerName, ReportDate, Format, ReleaseDate, CourseID, LectureNumber, PurchaseChannel,
Library, State, PostalCode, ZipCode, CourseName, Title, TGC_ReleaseDate, SubjectCategory, SubjectCategory2, Topic, SubTopic, TGCPlusSubjectCategory,
PrimaryWebCategory, City, ZipCodeType, Population, DMlastupdated, county
; 
GO
