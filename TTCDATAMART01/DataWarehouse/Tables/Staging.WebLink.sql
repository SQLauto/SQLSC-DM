CREATE TABLE [Staging].[WebLink]
(
[WebLinkID] [int] NOT NULL,
[CourseID] [int] NULL,
[LinkType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Link] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SummaryDescription] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Author] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISBN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModifiedDate] [datetime] NULL,
[LastModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [tinyint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
