CREATE TABLE [Magento].[catalog_product_entity_int]
(
[value_id] [int] NOT NULL,
[entity_type_id] [int] NOT NULL,
[attribute_id] [smallint] NOT NULL,
[store_id] [smallint] NOT NULL,
[entity_id] [int] NOT NULL,
[value] [int] NULL CONSTRAINT [DF__catalog_p__value__25869641] DEFAULT (NULL)
) ON [PRIMARY]
GO
