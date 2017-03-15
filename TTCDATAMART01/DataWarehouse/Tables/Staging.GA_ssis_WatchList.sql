CREATE TABLE [Staging].[GA_ssis_WatchList]
(
[Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hour] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Minute] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventAction] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventLabel] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Users ] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
