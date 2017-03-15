CREATE TABLE [Magento].[tgc_upsell_my_digital_library]
(
[list_id] [smallint] NOT NULL,
[recommended_course_rank] [smallint] NOT NULL,
[recommended_course_id] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Magento].[tgc_upsell_my_digital_library] ADD CONSTRAINT [PK__tgc_upse__701F7C2A9D53A5A7] PRIMARY KEY CLUSTERED  ([list_id], [recommended_course_rank]) ON [PRIMARY]
GO
