CREATE TABLE [Staging].[vl_ssis_CreditcardretryReport]
(
[UserID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RetryCount] [int] NULL,
[RetryStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeclinedDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Nextretrydate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Originalbillingdate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Declinedcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeclinedMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
