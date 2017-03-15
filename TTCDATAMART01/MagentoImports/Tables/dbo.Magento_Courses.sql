CREATE TABLE [dbo].[Magento_Courses]
(
[CourseID] [int] NOT NULL,
[Store] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Bibliography] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseSummary] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Meta_Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Meta_Keyword] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Meta_Title] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Short_Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[url_key] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[url_path] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
