CREATE TABLE [Archive].[Stripe_transactions_report]
(
[id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created] [datetime] NULL,
[Amount] [float] NULL,
[AmountRefunded] [float] NULL,
[Currency] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConvertedAmount] [float] NULL,
[ConvertedAmountRefunded] [float] NULL,
[Fee] [float] NULL,
[Tax] [float] NULL,
[ConvertedCurrency] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatementDescriptor] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerDescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerEmail] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Captured] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardLast4] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardBrand] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardFunding] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardExpMonth] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardExpYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardAddressLine1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardAddressLine2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardAddressCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardAddressState] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardAddressCountry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardAddressZip] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardIssueCountry] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardFingerprint] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardCVCStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardAVSZipStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardAVSLine1Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardTokenizationMethod] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisputedAmount] [float] NULL,
[DisputeStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisputeReason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisputeDate] [datetime] NULL,
[DisputeEvidenceDue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentSourceType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destination] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Transfer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransferGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userId_metadata] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxAmount_metadata] [float] NULL,
[siteName_metadata] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[siteId_metadata] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[preTaxAmount_metadata] [float] NULL,
[captureReferenceId_metadata] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscriptionPlanId_metadata] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscriptionPlanIdentifier_metadata] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userEmail_metadata] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
