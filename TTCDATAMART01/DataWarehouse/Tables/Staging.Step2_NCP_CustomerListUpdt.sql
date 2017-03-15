CREATE TABLE [Staging].[Step2_NCP_CustomerListUpdt]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdCode] [int] NOT NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[Concatenated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagHoldOut] [smallint] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjRank] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [date] NULL,
[Catalogcode] [int] NOT NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cat_StartDate] [datetime] NULL,
[Cat_StopDate] [datetime] NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MultiOrsingle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverallSales_ActRecips_03Mo] [money] NULL,
[OverallOrders_ActRecips_03Mo] [int] NULL,
[CourseSales_ActRecips_03Mo] [money] NULL,
[CourseOrders_ActRecips_03Mo] [int] NULL,
[CourseDrvnSales_ActRecips_03Mo] [money] NULL,
[CourseDrvnOrders_ActRecips_03Mo] [int] NULL,
[OverallSales_ActRecips_CatLf] [money] NULL,
[OverallOrders_ActRecips_CatLf] [int] NULL,
[CourseSales_ActRecips_CatLf] [money] NULL,
[CourseOrders_ActRecips_CatLf] [int] NULL,
[CourseDrvnSales_ActRecips_CatLf] [money] NULL,
[CourseDrvnOrders_ActRecips_CatLf] [int] NULL,
[OverallSales_ActRecips_Coded] [money] NULL,
[OverallOrders_ActRecips_Coded] [int] NULL,
[CourseSales_ActRecips_Coded] [money] NULL,
[CourseOrders_ActRecips_Coded] [int] NULL,
[CourseDrvnSales_ActRecips_Coded] [money] NULL,
[CourseDrvnOrders_ActRecips_Coded] [int] NULL,
[OverallSales_ActRecips_01Mo] [money] NULL,
[OverallOrders_ActRecips_01Mo] [int] NULL,
[CourseSales_ActRecips_01Mo] [money] NULL,
[CourseOrders_ActRecips_01Mo] [int] NULL,
[CourseDrvnSales_ActRecips_01Mo] [money] NULL,
[CourseDrvnOrders_ActRecips_01Mo] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_Step2_NCP_CustomerListUpdt1] ON [Staging].[Step2_NCP_CustomerListUpdt] ([Catalogcode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Step2_NCP_CustomerListUpdt2] ON [Staging].[Step2_NCP_CustomerListUpdt] ([CustomerID]) ON [PRIMARY]
GO
