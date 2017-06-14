CREATE TABLE [Staging].[HoursPerActiveSub]
(
[AsofDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TGCCustomerFlag] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Customers] [int] NULL,
[StreamedMinutes] [decimal] (38, 1) NULL
) ON [PRIMARY]
GO
