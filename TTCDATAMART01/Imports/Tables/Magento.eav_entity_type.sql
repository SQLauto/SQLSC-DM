CREATE TABLE [Magento].[eav_entity_type]
(
[entity_type_id] [smallint] NOT NULL,
[entity_type_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[entity_model] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[attribute_model] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entity_table] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value_table_prefix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entity_id_field] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_data_sharing] [smallint] NOT NULL,
[data_sharing_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_attribute_set_id] [smallint] NOT NULL,
[increment_model] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[increment_per_store] [smallint] NOT NULL,
[increment_pad_length] [smallint] NOT NULL,
[increment_pad_char] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[additional_attribute_table] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entity_attribute_collection] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
