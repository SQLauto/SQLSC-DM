CREATE TABLE [dbo].[OmniLite_Cust1]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateOrdered] [datetime] NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmail] [int] NULL,
[fmpulldate] [datetime] NULL,
[CountryCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DVD] [int] NOT NULL,
[NumDVDs] [int] NOT NULL,
[CD] [int] NOT NULL,
[NumCDs] [int] NOT NULL
) ON [PRIMARY]
GO
