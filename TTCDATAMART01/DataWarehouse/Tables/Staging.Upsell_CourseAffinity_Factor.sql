CREATE TABLE [Staging].[Upsell_CourseAffinity_Factor]
(
[SP_CourseID] [int] NULL,
[SP_ReleaseDate] [datetime] NULL,
[TotalSP_SinceRelease] [float] NULL,
[TotalSP_All] [float] NULL,
[SP_CourseAffFactor] [float] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Upsell_CourseAffinity_Factor] ON [Staging].[Upsell_CourseAffinity_Factor] ([SP_CourseID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Upsell_CourseAffinity_Factor2] ON [Staging].[Upsell_CourseAffinity_Factor] ([SP_ReleaseDate]) ON [PRIMARY]
GO
