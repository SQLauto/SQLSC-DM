CREATE TABLE [Magento].[tgc_upsell_location]
(
[location_id] [tinyint] NOT NULL,
[location_name] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[table_name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[is_course_required] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Magento].[tgc_upsell_location] ADD CONSTRAINT [PK__tgc_upse__771831EAEF9A3D20] PRIMARY KEY CLUSTERED  ([location_id]) ON [PRIMARY]
GO
