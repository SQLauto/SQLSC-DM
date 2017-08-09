CREATE TABLE [Staging].[TGC_upsell_MBA_CourseRank]
(
[PrimaryCourseid] [int] NULL,
[SecondaryCourseid] [int] NULL,
[SecondaryCourseparts] [int] NULL,
[PrimaryCoursePurchaseCnts] [int] NULL,
[SecondaryCoursePurchaseCnts] [int] NULL,
[BothCoursesPurchaseCounts] [int] NULL,
[TotalCustomerCnts] [int] NULL,
[Support] [float] NULL,
[Confidence] [float] NULL,
[ExpectedConfidence] [float] NULL,
[Lift] [float] NULL,
[AdjScore] [float] NULL,
[FinalRank] [bigint] NULL,
[DMLastUpdated] [datetime] NULL
) ON [PRIMARY]
GO
