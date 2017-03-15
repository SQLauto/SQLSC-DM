CREATE TABLE [Mapping].[FIG01FIGMASTER]
(
[FigID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FIGSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagUSEorNOT] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIGTitle] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectAssociation] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectAssociation_Original] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUBJECTASSOCIATION_MODIFIED] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromCourseID] [int] NULL,
[Course1Asc] [int] NULL,
[Course2Asc] [int] NULL,
[HTML_Link] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateFirstRun] [datetime] NULL,
[JoinID] [tinyint] NULL
) ON [PRIMARY]
GO
