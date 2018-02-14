SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_SMR_Audible_20180208]
AS
SELECT
  PartnerName AS Platform,
  CAST(D.Date AS date) AS ReportDate,
  s.CourseID,
  CAST(ReleaseDate AS date) ReleaseDate,
  CAST(x.TGCReleaseDate AS date)
  TGCReleaseDate,
  EOMonth(ReportDate) Endofmonth,
  x.CourseName,
  x.PrimaryWebCategory,
  (Units) * 1. / Days AS [Units],
  SUM(Revenue) / Days AS [Revenue]
FROM DataWarehouse.Mapping.DATE(nolock) D
JOIN (SELECT
  Year,
  Month,
  COUNT(Date) AS Days
FROM DataWarehouse.Mapping.DATE(nolock)
GROUP BY Year,
         Month) D1
  ON D1.Month = D.Month
  AND D1.Year = D.Year
JOIN archive.Vw_Tb_Audible_sales(nolock) s
  ON D.Year = YEAR(S.ReportDate)
  AND D.Month = MONTH(S.ReportDate)
LEFT JOIN (SELECT DISTINCT
  courseid,
  coursename,
  PrimaryWebCategory,
  ReleaseDate AS TGCReleaseDate
FROM staging.Vw_DMCourse(nolock)
WHERE BundleFlag = 0
AND CourseID > 0) x
  ON s.CourseID = x.CourseID
/* where s.CourseID = 174  and EOMonth(ReportDate) = '2013-11-30'*/ GROUP BY PartnerName,
                                                                             CAST(D.Date AS date),
                                                                             s.CourseID,
                                                                             CAST(ReleaseDate AS date),
                                                                             Days,
                                                                             units,
                                                                             EOMonth(ReportDate),
                                                                             x.CourseName,
                                                                             x.PrimaryWebCategory,
                                                                             x.TGCReleaseDate
UNION ALL
/* Weekly File*/ SELECT
  'Audible' AS Platform,
  CAST(D.Date AS date) ReportDate,
  s.CourseID,
  CAST(ReleaseDate AS date) ReleaseDate,
  CAST(x.TGCReleaseDate AS date)
  TGCReleaseDate,
  EOMonth(WeekEnding) Endofmonth,
  x.CourseName,
  x.PrimaryWebCategory,
  SUM(TotalNetUnits) / Days Units,
  SUM(TotalNetPayments)
  / Days AS Revenue
FROM DataWarehouse.Mapping.DATE(nolock) D
JOIN (SELECT
  Year,
  Month,
  COUNT(Date) AS Days
FROM DataWarehouse.Mapping.DATE(nolock)
GROUP BY Year,
         Month) D1
  ON D1.Month = D.Month
  AND D1.Year = D.Year
JOIN archive.Audible_Weekly_Sales(nolock) s
  ON D.Year = YEAR(S.WeekEnding)
  AND D.Month = MONTH(S.WeekEnding)
LEFT JOIN (SELECT DISTINCT
  courseid,
  coursename,
  PrimaryWebCategory,
  ReleaseDate AS TGCReleaseDate
FROM staging.Vw_DMCourse(nolock)
WHERE BundleFlag = 0
AND CourseID > 0) x
  ON s.CourseID = x.CourseID
/* where s.CourseID = 174  */ GROUP BY CAST(D.Date AS date),
                                       s.CourseID,
                                       CAST(ReleaseDate AS date),
                                       Days,
                                       EOMonth(WeekEnding),
                                       x.CourseName,
                                       x.PrimaryWebCategory,
                                       CAST(x.TGCReleaseDate AS date)
GO
