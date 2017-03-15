CREATE TABLE [dbo].[UnqHardbounces_2015]
(
[BounceID] [float] NULL,
[CustomerID] [float] NULL,
[EmailAddress] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BounceReason] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BounceDate] [datetime] NULL,
[EmailTable] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
