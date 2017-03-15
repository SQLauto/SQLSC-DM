CREATE TABLE [Marketing].[Demographics_WD_YOY_NewCust]
(
[InitalPurchaseYear] [int] NULL,
[InitalPurchaseMonth] [int] NULL,
[IntlAgeBin_WD] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Income_WD] [varchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education_WD] [varchar] (27) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender_WD] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerAcqYear] [varchar] (43) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HHIncomeBin_WD] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NetWorth] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustCount] [int] NULL
) ON [PRIMARY]
GO
