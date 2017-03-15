CREATE TABLE [Mapping].[UpsellCourseRankBKP]
(
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCat] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AbbrSC] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlFormatAVPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rank] [int] NOT NULL,
[CourseID] [int] NOT NULL,
[SegmentGroup] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
