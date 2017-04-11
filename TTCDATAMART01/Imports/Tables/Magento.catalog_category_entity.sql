CREATE TABLE [Magento].[catalog_category_entity]
(
[entity_id] [int] NOT NULL,
[entity_type_id] [smallint] NOT NULL,
[attribute_set_id] [smallint] NOT NULL,
[parent_id] [int] NOT NULL,
[created_at] [datetime] NULL,
[updated_at] [datetime] NULL,
[path] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position] [int] NOT NULL,
[level] [int] NOT NULL,
[children_count] [int] NOT NULL,
[legacy_id] [int] NULL
) ON [PRIMARY]
GO
