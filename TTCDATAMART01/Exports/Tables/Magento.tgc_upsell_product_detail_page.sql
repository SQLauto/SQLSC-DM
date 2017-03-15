CREATE TABLE [Magento].[tgc_upsell_product_detail_page]
(
[list_id] [smallint] NOT NULL,
[course_id] [smallint] NOT NULL,
[recommended_course_rank] [smallint] NOT NULL,
[recommended_course_id] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Magento].[tgc_upsell_product_detail_page] ADD CONSTRAINT [PK__tgc_upse__73D7069E9017C4BD] PRIMARY KEY CLUSTERED  ([list_id], [course_id], [recommended_course_rank]) ON [PRIMARY]
GO
