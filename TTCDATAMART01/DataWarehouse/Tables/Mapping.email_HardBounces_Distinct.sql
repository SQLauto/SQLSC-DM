CREATE TABLE [Mapping].[email_HardBounces_Distinct]
(
[BounceID] [int] NOT NULL,
[CustomerID] [int] NOT NULL,
[EmailAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BounceReason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BounceDate] [datetime] NULL,
[EmailTable] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
