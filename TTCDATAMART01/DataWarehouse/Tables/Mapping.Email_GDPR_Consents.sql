CREATE TABLE [Mapping].[Email_GDPR_Consents]
(
[RespondantNum] [int] NULL,
[SubmitDate] [datetime] NULL,
[Email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsentInfo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastUpdateDate] [datetime] NULL
) ON [PRIMARY]
GO
