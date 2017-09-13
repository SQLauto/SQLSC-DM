CREATE TABLE [Archive].[TGCPlus_Android_Subscriptions]
(
[Date] [datetime] NULL,
[PackageName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSubscriptions] [int] NULL,
[CancelledSubscriptions] [int] NULL,
[ActiveSubscriptions] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__TGCPlus_A__DMLas__50305F68] DEFAULT (getdate())
) ON [PRIMARY]
GO
