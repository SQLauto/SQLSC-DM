CREATE TABLE [Archive].[tgc_upsell_ContactCenter_20161209]
(
[tgc_upsell_ContactCenter_id] [int] NOT NULL IDENTITY(1, 1),
[list_id] [smallint] NOT NULL,
[course_id] [smallint] NOT NULL,
[recommended_course_rank] [smallint] NOT NULL,
[recommended_course_id] [smallint] NOT NULL,
[Last_Updated_Date] [datetime] NOT NULL
) ON [PRIMARY]
GO
