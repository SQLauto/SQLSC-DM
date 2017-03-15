CREATE TABLE [Archive].[TGCPlus_PaymentAuthorizationUsedOffer]
(
[pa_id] [bigint] NULL,
[pa_user_id] [bigint] NULL,
[uso_id] [bigint] NOT NULL,
[uso_version] [bigint] NULL,
[uso_applied_at] [datetime] NULL,
[uso_offer_id] [bigint] NULL,
[uso_offer_code_applied] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uso_redeemed_at] [datetime] NULL,
[uso_uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uso_update_date] [datetime] NULL,
[DMLastUpdateESTDateTime] [datetime] NOT NULL CONSTRAINT [DF__TGCPlus_P__DMLas__20E0A99B] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TGCplus_PaymentAuthorizationusedoffer] ON [Archive].[TGCPlus_PaymentAuthorizationUsedOffer] ([uso_id]) ON [PRIMARY]
GO
