CREATE TABLE [Archive].[FIG01FIGMASTER]
(
[FIGID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FIGSource] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagUSEorNOT] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldFIGTitle] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectAssociation] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectAssociation_Original] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectAssociation_Modified] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromCourseID] [float] NULL,
[Course1Asc] [float] NULL,
[Course2Asc] [float] NULL,
[HTMLLink] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateFirstRun] [smalldatetime] NULL,
[JoinID] [int] NULL,
[FIGTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
