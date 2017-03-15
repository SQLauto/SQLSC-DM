CREATE TABLE [Marketing].[DOMO_HouseSpendSummary]
(
[AsOfDate] [date] NOT NULL,
[AsOfMonth] [tinyint] NOT NULL,
[AsOfYear] [smallint] NOT NULL,
[NewSeg] [tinyint] NOT NULL,
[Name] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[A12MF] [tinyint] NOT NULL,
[CustomerSegment] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3SubjectPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[R3OrderSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagEmailPref] [tinyint] NULL,
[FlagEmailValid] [tinyint] NULL,
[FlagEmailable] [tinyint] NULL,
[FlagMailPref] [tinyint] NULL,
[CountryCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalesSubsqMnth] [money] NULL,
[OrdersSubsqMnth] [int] NULL,
[UnitsSubsqMnth] [int] NULL,
[PartsSubsqMnth] [dbo].[udtCourseParts] NULL,
[HoursSubsqMnt] [money] NULL,
[CustCount] [int] NULL
) ON [PRIMARY]
GO
