CREATE TABLE [Staging].[Android_ssis_Subscriptions]
(
[Date] [datetime] NULL,
[PackageName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSubscriptions] [int] NULL,
[CancelledSubscriptions] [int] NULL,
[ActiveSubscriptions] [int] NULL
) ON [PRIMARY]
GO
