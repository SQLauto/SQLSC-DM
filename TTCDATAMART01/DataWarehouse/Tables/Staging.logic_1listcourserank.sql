CREATE TABLE [Staging].[logic_1listcourserank]
(
[ListID] [smallint] NULL,
[ListName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Courseid] [smallint] NULL,
[DisplayOrder] [smallint] NULL,
[UpsellCourseID] [smallint] NULL,
[DMLastUpdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
