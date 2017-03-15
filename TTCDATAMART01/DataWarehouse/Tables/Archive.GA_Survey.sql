CREATE TABLE [Archive].[GA_Survey]
(
[UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Action] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventLabel] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Users] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__GA_Survey__DMLas__5A22E0D5] DEFAULT (getdate())
) ON [PRIMARY]
GO
