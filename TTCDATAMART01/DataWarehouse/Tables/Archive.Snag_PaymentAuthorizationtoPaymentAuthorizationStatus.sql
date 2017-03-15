CREATE TABLE [Archive].[Snag_PaymentAuthorizationtoPaymentAuthorizationStatus]
(
[payment_authorization_status_history_id] [bigint] NULL,
[payment_authorization_status_id] [bigint] NULL,
[DMLastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__Snag_Paym__Lastu__6651B34E] DEFAULT (getdate())
) ON [PRIMARY]
GO
