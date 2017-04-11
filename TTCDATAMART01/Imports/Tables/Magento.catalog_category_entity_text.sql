CREATE TABLE [Magento].[catalog_category_entity_text]
(
[value_id] [int] NOT NULL,
[entity_type_id] [smallint] NOT NULL,
[attribute_id] [smallint] NOT NULL,
[store_id] [smallint] NOT NULL,
[entity_id] [int] NOT NULL,
[value] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
