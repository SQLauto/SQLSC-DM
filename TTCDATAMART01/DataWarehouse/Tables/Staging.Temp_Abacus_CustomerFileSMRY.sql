CREATE TABLE [Staging].[Temp_Abacus_CustomerFileSMRY]
(
[AsOfDate] [date] NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagDoNotMail] [int] NOT NULL,
[FlagDoNotShare] [int] NOT NULL,
[FlagMailable] [int] NULL,
[FlagEmailable] [int] NULL,
[FlagEmailPreference] [int] NULL,
[FlagValidEmail] [tinyint] NULL,
[FormatPreference] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectPreference] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearSince] [int] NULL,
[MonthSince] [int] NULL,
[IntlOrderYear] [int] NULL,
[IntlOrderMonth] [int] NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RFMComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustCount] [int] NULL,
[TotalSales] [money] NULL,
[TotalOrders] [int] NULL
) ON [PRIMARY]
GO
