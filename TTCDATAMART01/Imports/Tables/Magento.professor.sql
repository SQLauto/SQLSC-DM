CREATE TABLE [Magento].[professor]
(
[professor_id] [int] NOT NULL,
[first_name] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_name] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[qual] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bio] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rank] [int] NULL,
[quote] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[title] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[category_id] [int] NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[facebook] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[twitter] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pinterest] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[youtube] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[photo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[testimonial] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[import_row_num] [int] NULL,
[url_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[meta_title] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[meta_keywords] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[meta_description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
