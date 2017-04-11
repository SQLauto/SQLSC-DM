CREATE TABLE [Magento].[catalog_category_entity_varchar]
(
[value_id] [int] NOT NULL,
[entity_type_id] [smallint] NOT NULL,
[attribute_id] [smallint] NOT NULL,
[store_id] [smallint] NOT NULL,
[entity_id] [int] NOT NULL,
[value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__catalog_c__value__2E1BDC42] DEFAULT (NULL)
) ON [PRIMARY]
GO
