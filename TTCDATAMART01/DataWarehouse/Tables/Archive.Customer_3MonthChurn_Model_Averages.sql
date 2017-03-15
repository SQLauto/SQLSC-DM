CREATE TABLE [Archive].[Customer_3MonthChurn_Model_Averages]
(
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[Avg_Age] [numeric] (38, 6) NULL,
[Avg_OptCount] [numeric] (38, 6) NULL,
[Avg_IntlSales] [numeric] (38, 6) NULL,
[Avg_VisitRecencyDays] [float] NULL,
[Avg_Male] [numeric] (38, 6) NULL,
[Avg_ProdView] [numeric] (38, 6) NULL,
[Avg_IntlSubjectPref2] [numeric] (38, 6) NULL,
[Avg_IntlSubjectPref3] [numeric] (38, 6) NULL,
[Avg_IntlSubjectPref4] [numeric] (38, 6) NULL,
[Avg_IntlSubjectPref5] [numeric] (38, 6) NULL,
[Avg_IntlSubjectPref6] [numeric] (38, 6) NULL,
[IntlOrderSource2] [numeric] (38, 6) NULL,
[IntlOrderSource3] [numeric] (38, 6) NULL,
[IntlOrderSource4] [numeric] (38, 6) NULL,
[Min_ModelScore] [float] NULL,
[Max_ModelScore] [float] NULL,
[Avg_ModelScore] [float] NULL,
[DMLastupdatedate] [datetime] NOT NULL
) ON [PRIMARY]
GO
