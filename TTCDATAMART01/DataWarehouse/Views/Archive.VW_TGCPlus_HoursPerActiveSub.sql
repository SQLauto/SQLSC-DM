SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[VW_TGCPlus_HoursPerActiveSub]
AS
SELECT        AsofDate, TGCCustomerFlag, Customers, StreamedMinutes, CAST(AsofDate AS date) AS AsofDate_Conv
FROM            (SELECT        '2017-03-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                    COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                    Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '4/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-03-01') AND (CONVERT(date, b.TSTAMP) 
                                                    <= '2017-03-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2017-02-28' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '3/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-02-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2017-02-28')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2017-01-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '2/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-01-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2017-01-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-03-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '4/1/2016') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-03-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-03-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-02-28' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '3/1/2016') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-02-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-02-28')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-01-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '2/1/2016') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-01-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-01-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-04-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '5/1/2016') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-04-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-04-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-05-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '6/1/2016') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-05-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-05-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-06-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '7/1/2016') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-06-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-06-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-07-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '8/1/2016') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-07-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-07-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-08-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '9/1/2016') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-08-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-08-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-09-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '10/1/2016') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-09-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-09-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-10-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '11/1/2016') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-10-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-10-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-11-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '12/1/2016') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-11-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-11-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2016-12-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '01/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2016-12-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2016-12-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2017-04-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '5/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-04-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2017-04-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2017-05-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '6/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-05-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2017-05-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2017-06-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '7/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-06-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2017-06-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2017-07-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '8/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-07-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2017-07-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2017-08-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '9/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-08-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2017-08-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2017-09-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '10/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-09-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2017-09-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2017-10-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '11/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-10-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2017-10-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2017-11-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '12/1/2017') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-11-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2017-11-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2017-12-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '01/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2017-12-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2017-12-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-03-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '4/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-03-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-03-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-02-28' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '3/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-02-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-02-28')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-01-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '2/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-01-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-01-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-04-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '5/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-04-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-04-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-05-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '6/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-05-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-05-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-06-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '7/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-06-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-06-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-07-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '8/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-07-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-07-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-08-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '9/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-08-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-08-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-09-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '10/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-09-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-09-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-10-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '11/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-10-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-10-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-11-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '12/1/2018') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-11-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-11-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2018-12-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '01/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2018-12-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2018-12-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-03-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '4/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-03-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-03-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-02-28' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '3/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-02-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-02-28')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-01-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '2/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-01-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-01-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-04-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '5/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-04-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-04-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-05-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '6/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-05-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-05-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-06-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '7/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-06-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-06-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-07-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '8/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-07-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-07-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-08-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '9/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-08-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-08-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-09-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '10/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-09-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-09-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-10-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '11/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-10-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-10-31')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-11-30' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '12/1/2019') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-11-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-11-30')
                          GROUP BY a.TGCCustFlag
                          UNION ALL
                          SELECT        '2019-12-31' AS AsofDate, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerFlag, 
                                                   COUNT(DISTINCT a.CustomerID) AS Customers, SUM(b.StreamedMins) AS StreamedMinutes
                          FROM            Marketing.TGCPlus_CustomerSignature_Snapshot AS a WITH (nolock) LEFT OUTER JOIN
                                                   Marketing.TGCplus_VideoEvents_Smry AS b WITH (nolock) ON a.uuid = b.UUID
                          WHERE        (a.AsofDate = '01/1/2020') AND (a.CustStatusFlag <> - 1) AND (CONVERT(date, b.TSTAMP) >= '2019-12-01') AND (CONVERT(date, b.TSTAMP) 
                                                   <= '2019-12-31')
                          GROUP BY a.TGCCustFlag) AS Agg
WHERE        (AsofDate <=
                             (SELECT        MAX(AsofDate) AS Expr1
                               FROM            Marketing.TGCPlus_CustomerSignature_Snapshot WITH (nolock)))
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Agg"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'Archive', 'VIEW', N'VW_TGCPlus_HoursPerActiveSub', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'Archive', 'VIEW', N'VW_TGCPlus_HoursPerActiveSub', NULL, NULL
GO
