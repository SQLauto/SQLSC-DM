CREATE TABLE [Magento].[tgc_upsell_list]
(
[list_id] [smallint] NOT NULL,
[location_id] [tinyint] NOT NULL,
[course_id] [smallint] NOT NULL,
[list_name] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Magento].[tgc_upsell_list] ADD CONSTRAINT [PK__tgc_upse__63606CDCB1E30063] PRIMARY KEY CLUSTERED  ([list_id], [location_id], [course_id]) ON [PRIMARY]
GO
