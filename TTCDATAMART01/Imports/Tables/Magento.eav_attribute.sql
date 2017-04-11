CREATE TABLE [Magento].[eav_attribute]
(
[attribute_id] [smallint] NOT NULL,
[entity_type_id] [smallint] NOT NULL,
[attribute_code] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attribute_model] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[backend_model] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[backend_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[backend_table] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frontend_model] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frontend_input] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frontend_label] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frontend_class] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[source_model] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_required] [smallint] NOT NULL,
[is_user_defined] [smallint] NOT NULL,
[default_value] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_unique] [smallint] NOT NULL,
[note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
