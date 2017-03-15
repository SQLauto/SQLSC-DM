CREATE TABLE [Staging].[Upsell_CourseAffinity_Temp]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateOrdered] [datetime] NULL,
[CourseID] [int] NULL,
[Parts] [dbo].[udtCourseParts] NULL,
[CSATScore] [float] NULL,
[CourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategoryID] [int] NULL,
[ReleaseDate] [datetime] NULL,
[TotalSales] [money] NULL,
[SP_OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SP_DateOrdered] [datetime] NULL,
[PriorPurchaseOrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_CourseID] [int] NULL,
[SP_Parts] [dbo].[udtCourseParts] NULL,
[SP_CSATScore] [float] NULL,
[SP_CourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SP_SubjectCategoryID] [int] NULL,
[SP_ReleaseDate] [datetime] NULL,
[SP_DaysSinceRelease] [int] NULL,
[SP_TotalSales] [money] NULL,
[FP_StartDate] [datetime] NULL,
[FP_EndDate] [datetime] NULL,
[ReportDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_Upsell_CourseAffinity_Temp_FC] ON [Staging].[Upsell_CourseAffinity_Temp] ([CourseID], [CourseName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Upsell_CourseAffinity_Temp_SC] ON [Staging].[Upsell_CourseAffinity_Temp] ([SP_CourseID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Upsell_CourseAffinity_Temp_SDO] ON [Staging].[Upsell_CourseAffinity_Temp] ([SP_DateOrdered]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Upsell_CourseAffinity_Temp_SRD] ON [Staging].[Upsell_CourseAffinity_Temp] ([SP_ReleaseDate]) ON [PRIMARY]
GO
