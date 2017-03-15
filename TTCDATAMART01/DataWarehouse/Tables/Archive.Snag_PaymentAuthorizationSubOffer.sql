CREATE TABLE [Archive].[Snag_PaymentAuthorizationSubOffer]
(
[payment_authorization_usedoffers_id] [bigint] NULL,
[used_subscription_offer_id] [bigint] NULL,
[DMLastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__Snag_Paym__Lastu__74168E17] DEFAULT (getdate())
) ON [PRIMARY]
GO
