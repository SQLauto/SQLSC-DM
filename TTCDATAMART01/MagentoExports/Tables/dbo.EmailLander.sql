CREATE TABLE [dbo].[EmailLander]
(
[email_landing_category] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[course_id] [int] NOT NULL,
[displayorder] [float] NOT NULL,
[markdown_flag] [bit] NULL,
[lander_msg] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[category_expires] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
