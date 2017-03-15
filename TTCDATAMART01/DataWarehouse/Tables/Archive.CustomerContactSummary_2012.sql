CREATE TABLE [Archive].[CustomerContactSummary_2012]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCustomerAdded] [datetime] NOT NULL,
[ContactYear] [int] NULL,
[ContactMonth] [int] NULL,
[TotalMails] [int] NOT NULL,
[TotalEmails] [int] NOT NULL,
[TotalCatalogs] [int] NULL,
[TotalCatalogReactivation] [int] NULL,
[TotalMagalogs] [int] NULL,
[TotalMagazines] [int] NULL,
[TotalNewsLetters] [int] NULL,
[TotalJFYLetters] [int] NULL,
[TotalMag7s] [int] NULL,
[TotalMagBacks] [int] NULL,
[TotalHOMs] [int] NULL,
[TotalSpecialMailings] [int] NULL,
[TotalWelcomePakcage] [int] NOT NULL,
[TotalConvertalog] [int] NOT NULL,
[TotalOtherMailings] [int] NULL,
[TotalMailsQC] [int] NOT NULL
) ON [PRIMARY]
GO
