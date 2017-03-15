CREATE TABLE [Staging].[Temp_Abacus_Trans_WorkingSMRY]
(
[AsOfDate] [date] NULL,
[YearOrdered] [int] NULL,
[OrderStatusDescription] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionTypeID] [smallint] NULL,
[PromotionTypeDesc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sales] [money] NULL,
[Orders] [int] NULL
) ON [PRIMARY]
GO
