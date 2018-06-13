CREATE TABLE [Archive].[TGCPlus_GDPR_ForgetMe_AuditTrail]
(
[CustomerID] [bigint] NOT NULL,
[UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastUpdateESTDateTime] [datetime] NOT NULL,
[DateAdded] [datetime] NOT NULL,
[CleanupCompleted] [int] NOT NULL,
[CleanupCompletedDatetime] [datetime] NULL,
[TGCPlusCompleted] [bit] NULL,
[StripeCompleted] [bit] NULL,
[SailtruCompleted] [bit] NULL
) ON [PRIMARY]
GO
