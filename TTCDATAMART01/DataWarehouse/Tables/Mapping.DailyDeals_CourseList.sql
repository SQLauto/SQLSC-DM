CREATE TABLE [Mapping].[DailyDeals_CourseList]
(
[DateOnSale] [datetime] NOT NULL,
[CourseID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[DailyDeals_CourseList] ADD CONSTRAINT [PK_DailyDeals_CourseList] PRIMARY KEY CLUSTERED  ([DateOnSale], [CourseID]) ON [PRIMARY]
GO
