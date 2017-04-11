CREATE TABLE [Magento].[catalog_product_entity]
(
[entity_id] [int] NOT NULL,
[entity_type_id] [smallint] NOT NULL,
[attribute_set_id] [smallint] NOT NULL,
[type_id] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sku] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_options] [smallint] NOT NULL,
[required_options] [smallint] NOT NULL,
[created_at] [datetime] NULL,
[updated_at] [datetime] NULL,
[course_id] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
