CREATE TABLE [Mapping].[MktProfessor]
(
[ProfessorID] [int] NOT NULL,
[FirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfQual] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfessorBio] [varchar] (7000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasGif] [int] NULL,
[TeachInst] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfessorSubjectArea] [int] NULL,
[ProfessorRank] [float] NULL,
[ProfessorQuote] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
