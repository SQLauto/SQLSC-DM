CREATE TABLE [Magento].[MktWebEmailLander_Archive]
(
[CategoryID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CourseID] [int] NOT NULL,
[DisplayOrder] [float] NOT NULL,
[blnMarkdown] [bit] NULL,
[message] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expires] [datetime] NULL,
[datemoved] [datetime] NOT NULL,
[Date_Added] [datetime] NULL
) ON [PRIMARY]
GO
