CREATE TABLE [Archive].[TGCPLus_CreditcardretryReport]
(
[UserID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RetryCount] [int] NULL,
[RetryStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeclinedDate] [datetime] NULL,
[Nextretrydate] [datetime] NULL,
[Originalbillingdate] [datetime] NULL,
[Declinedcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeclinedMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMlastupdated] [datetime] NULL
) ON [PRIMARY]
GO
