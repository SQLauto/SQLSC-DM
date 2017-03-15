CREATE TABLE [Archive].[tgc_upsell_ContactCenter]
(
[tgc_upsell_ContactCenter_id] [int] NOT NULL IDENTITY(1, 1),
[list_id] [smallint] NOT NULL,
[course_id] [smallint] NOT NULL,
[recommended_course_rank] [smallint] NOT NULL,
[recommended_course_id] [smallint] NOT NULL,
[Last_Updated_Date] [datetime] NOT NULL CONSTRAINT [DF_tgc_upsell_ContactCenter_Last_Updated_Date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[tgc_upsell_ContactCenter] ADD CONSTRAINT [PK__tgc_upse__FA751AD0F6742768] PRIMARY KEY CLUSTERED  ([tgc_upsell_ContactCenter_id]) ON [PRIMARY]
GO
ALTER TABLE [Archive].[tgc_upsell_ContactCenter] ADD CONSTRAINT [UC_tgc_upsell_ContactCenter] UNIQUE NONCLUSTERED  ([list_id], [course_id], [recommended_course_rank]) ON [PRIMARY]
GO
