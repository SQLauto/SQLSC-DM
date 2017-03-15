CREATE TABLE [Archive].[tgc_upsell_just_for_you]
(
[list_id] [smallint] NOT NULL,
[recommended_course_rank] [smallint] NOT NULL,
[recommended_course_id] [smallint] NOT NULL,
[Last_Updated_Date] [datetime] NOT NULL CONSTRAINT [DF_tgc_upsell_just_for_you_Last_Updated_Date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[tgc_upsell_just_for_you] ADD CONSTRAINT [UC_tgc_upsell_Just_For_you] UNIQUE NONCLUSTERED  ([list_id], [recommended_course_rank]) ON [PRIMARY]
GO
