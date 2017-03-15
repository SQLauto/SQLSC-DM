CREATE TABLE [Archive].[tgc_upsell_my_digital_library]
(
[list_id] [smallint] NOT NULL,
[recommended_course_rank] [smallint] NOT NULL,
[recommended_course_id] [smallint] NOT NULL,
[Last_Updated_Date] [datetime] NOT NULL CONSTRAINT [DF_tgc_upsell_my_digital_library_Last_Updated_Date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[tgc_upsell_my_digital_library] ADD CONSTRAINT [UC_tgc_upsell_My_digital_library] UNIQUE NONCLUSTERED  ([list_id], [recommended_course_rank]) ON [PRIMARY]
GO
