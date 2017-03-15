CREATE TABLE [Archive].[tgc_upsell_product_detail_page]
(
[list_id] [smallint] NOT NULL,
[course_id] [smallint] NOT NULL,
[recommended_course_rank] [smallint] NOT NULL,
[recommended_course_id] [smallint] NOT NULL,
[Last_Updated_Date] [datetime] NOT NULL CONSTRAINT [DF_tgc_upsell_product_detail_page_Last_Updated_Date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[tgc_upsell_product_detail_page] ADD CONSTRAINT [UC_tgc_upsell_product_detail_page] UNIQUE NONCLUSTERED  ([list_id], [course_id], [recommended_course_rank]) ON [PRIMARY]
GO
