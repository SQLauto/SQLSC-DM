CREATE TABLE [Marketing].[DailyEmailMailFlagCheck]
(
[YearOf] [int] NULL,
[MonthOf] [int] NULL,
[DayOf] [int] NULL,
[AsOfDate] [datetime] NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentNew] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmail] [int] NULL,
[FlagEmailPref] [int] NULL,
[FlagValidEmail] [tinyint] NULL,
[FlagMail] [int] NULL,
[FlagValidRegionUS] [bit] NULL,
[CustCount] [int] NULL
) ON [PRIMARY]
GO
