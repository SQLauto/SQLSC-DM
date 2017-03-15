CREATE TABLE [Magento].[tgc_upsell_you_may_like]
(
[list_id] [smallint] NOT NULL,
[course_id] [smallint] NOT NULL,
[recommended_course_rank] [smallint] NOT NULL,
[recommended_course_id] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Magento].[tgc_upsell_you_may_like] ADD CONSTRAINT [PK__tgc_upse__73D7069E6C869FCF] PRIMARY KEY CLUSTERED  ([list_id], [course_id], [recommended_course_rank]) ON [PRIMARY]
GO
