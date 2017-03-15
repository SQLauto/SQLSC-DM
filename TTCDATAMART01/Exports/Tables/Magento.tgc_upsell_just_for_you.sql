CREATE TABLE [Magento].[tgc_upsell_just_for_you]
(
[list_id] [smallint] NOT NULL,
[recommended_course_rank] [smallint] NOT NULL,
[recommended_course_id] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Magento].[tgc_upsell_just_for_you] ADD CONSTRAINT [PK__tgc_upse__701F7C2A5EC6FC24] PRIMARY KEY CLUSTERED  ([list_id], [recommended_course_rank]) ON [PRIMARY]
GO
