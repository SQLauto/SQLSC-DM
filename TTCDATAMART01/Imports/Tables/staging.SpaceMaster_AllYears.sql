CREATE TABLE [staging].[SpaceMaster_AllYears]
(
[PlanYear] [float] NULL,
[Publication] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostForReporting] [money] NULL,
[CourseID] [float] NULL,
[ExpireDate] [datetime] NULL,
[BuffetFlag] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode_Control] [int] NULL,
[CatalogCode_Test] [int] NULL,
[AdCode_Control] [int] NULL,
[AdCode_Test] [int] NULL,
[URLAdCode_Control] [int] NULL,
[URLAdCode_Test] [int] NULL,
[Circulation] [float] NULL
) ON [PRIMARY]
GO
