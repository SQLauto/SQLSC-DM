CREATE TABLE [Magento].[MktWebEmailLander]
(
[CategoryID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CourseID] [int] NOT NULL,
[DisplayOrder] [float] NOT NULL,
[blnMarkdown] [bit] NULL CONSTRAINT [DF_MktWebEmailLander_blnMarkdown] DEFAULT ((0)),
[message] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expires] [datetime] NULL,
[Date_Added] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Magento].[MktWebEmailLander] ADD CONSTRAINT [PK_MktWebEmailLander] PRIMARY KEY CLUSTERED  ([CategoryID], [CourseID]) ON [PRIMARY]
GO
