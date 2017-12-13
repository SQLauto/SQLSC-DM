CREATE TABLE [Marketing].[MonthlyMailCounts]
(
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Year] [int] NULL,
[Month] [int] NULL,
[MailContacts] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UC_MonthlyMailCounts] ON [Marketing].[MonthlyMailCounts] ([Customerid], [Year], [Month]) ON [PRIMARY]
GO
