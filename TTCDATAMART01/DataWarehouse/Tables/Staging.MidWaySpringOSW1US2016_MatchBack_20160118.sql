CREATE TABLE [Staging].[MidWaySpringOSW1US2016_MatchBack_20160118]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prefix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MiddleName] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Suffix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Address1] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Address2] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[State] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PostalCode] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlSales] [money] NOT NULL,
[IntlCourses] [int] NULL,
[IntlParts] [money] NULL,
[IntlOrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustSubjectPreference] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMediaType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlFormat] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlDateOrdered] [datetime] NULL,
[IntlAdCode] [int] NULL,
[LastDateOrdered] [datetime] NULL
) ON [PRIMARY]
GO
