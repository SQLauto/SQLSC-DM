CREATE TABLE [Magento].[catalog_product_entity_decimal]
(
[value_id] [int] NOT NULL,
[entity_type_id] [smallint] NOT NULL,
[attribute_id] [smallint] NOT NULL,
[store_id] [smallint] NOT NULL,
[entity_id] [int] NOT NULL,
[value] [decimal] (12, 4) NULL
) ON [PRIMARY]
GO
