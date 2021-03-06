CREATE TABLE [Archive].[TGCplus_DS]
(
[CustomerID] [bigint] NULL,
[DSDate] [date] NULL,
[DS] [int] NULL,
[DSDays] [int] NULL,
[EntitlementDays] [int] NULL,
[DS_Service_period_from] [datetime] NULL,
[DS_Service_period_to] [datetime] NULL,
[DS_Month] [int] NULL,
[DS_ValidDS] [int] NULL,
[DS_Entitled] [int] NULL,
[completed_at] [datetime] NULL,
[billing_cycle_period_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pre_tax_amount] [money] NULL,
[service_period_from] [datetime] NULL,
[service_period_to] [datetime] NULL,
[actual_service_period_to] [datetime] NULL,
[subscription_plan_id] [bigint] NULL,
[payment_handler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingRank] [bigint] NULL,
[Refunded] [bit] NULL,
[RefundedAmount] [money] NULL,
[Refunded_Completed_at] [datetime] NULL,
[Changed_Service_period_to] [bit] NULL,
[Changed_Billing_cycle_period_type] [bit] NULL,
[Changed_Subscription_plan_id] [bit] NULL,
[Changed_Payment_handler] [bit] NULL,
[PAS_Cancelled_date] [datetime] NULL,
[PAS_DeferredSuspension_date] [datetime] NULL,
[PAS_Suspended_date] [datetime] NULL,
[Cancelled] [int] NOT NULL,
[Suspended] [int] NOT NULL,
[DeferredSuspension] [int] NOT NULL,
[Prior_billing_cycle_period_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prior_subscription_plan_id] [bigint] NULL,
[Prior_payment_handler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount] [money] NULL,
[NetAmount] [money] NULL,
[DSSplits] [int] NULL,
[PaidFlag] [int] NULL,
[BillingDupes] [int] NULL,
[UBIssue] [bit] NULL,
[MinDS] [int] NULL,
[MinDSDate] [date] NULL,
[MaxDS] [int] NULL,
[MaxDSDate] [date] NULL,
[LTDAmount] [money] NULL,
[LTDNetAmount] [money] NULL,
[LTDPaymentRank] [int] NULL,
[LTDNetPaymentRank] [int] NULL,
[IntlDSbilling_cycle_period_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlDSsubscription_plan_id] [bigint] NULL,
[IntlDSpayment_handler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlDSAmount] [money] NULL,
[IntlDSuso_offer_id] [int] NULL,
[SubDSbilling_cycle_period_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubDSsubscription_plan_id] [bigint] NULL,
[SubDSpayment_handler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubDSAmount] [money] NULL,
[SubDSuso_offer_id] [int] NULL,
[CurrentDS] [int] NOT NULL,
[uso_offer_id] [int] NULL,
[uso_offer_code_applied] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uso_applied_at] [datetime] NULL,
[Reactivated] [bit] NULL,
[FreeTrialDays] [int] NULL,
[DMLastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TGCplus_DS_Cover1] ON [Archive].[TGCplus_DS] ([CustomerID], [CurrentDS], [DS]) ON [PRIMARY]
GO
