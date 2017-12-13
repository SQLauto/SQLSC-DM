CREATE TABLE [Archive].[tgc_upsell_Logic4ListCourseRank]
(
[PrimaryCourseid] [int] NULL,
[SecondaryCourseid] [int] NULL,
[PrimaryCourseparts] [int] NULL,
[SecondaryCourseparts] [int] NULL,
[Cluster] [int] NULL,
[ClusterCustomerCounts] [int] NULL,
[rank] [bigint] NULL,
[PrimaryCoursePurchaseCnts] [int] NULL,
[SecondaryCoursePurchaseCnts] [int] NULL,
[BothCoursesPurchaseCounts] [int] NULL,
[TotalCustomerCnts] [int] NULL,
[Support] [float] NULL,
[Confidence] [float] NULL,
[ExpectedConfidence] [float] NULL,
[Lift] [float] NULL,
[AdjScore] [float] NULL,
[FinalRank] [bigint] NULL
) ON [PRIMARY]
GO
