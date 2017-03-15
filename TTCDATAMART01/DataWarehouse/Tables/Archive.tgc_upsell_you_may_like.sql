CREATE TABLE [Archive].[tgc_upsell_you_may_like]
(
[list_id] [smallint] NOT NULL,
[course_id] [smallint] NOT NULL,
[recommended_course_rank] [smallint] NOT NULL,
[recommended_course_id] [smallint] NOT NULL,
[Last_Updated_Date] [datetime] NOT NULL CONSTRAINT [DF_tgc_upsell_you_may_like_Last_Updated_Date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[tgc_upsell_you_may_like] ADD CONSTRAINT [UC_tgc_upsell_you_may_like] UNIQUE NONCLUSTERED  ([list_id], [course_id], [recommended_course_rank]) ON [PRIMARY]
GO
