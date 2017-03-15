CREATE TABLE [Mapping].[WebFreeLectureCategory]
(
[CategoryID] [int] NOT NULL,
[SiteID] [int] NULL,
[CategoryName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[LecturesAvailableUntil] [datetime] NULL,
[CategoryFormat] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
