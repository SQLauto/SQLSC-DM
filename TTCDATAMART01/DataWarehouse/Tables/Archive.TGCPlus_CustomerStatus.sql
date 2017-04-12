CREATE TABLE [Archive].[TGCPlus_CustomerStatus]
(
[Customerid] [bigint] NULL,
[id] [bigint] NOT NULL,
[EventRank] [bigint] NULL,
[Eventdate] [datetime] NULL,
[Event] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Eventstatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plan_id] [bigint] NULL,
[SubType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_handler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payment] [real] NULL,
[RefundFlag] [int] NOT NULL,
[UpdatedServicePeriodToFlag] [bit] NOT NULL,
[service_period_from] [datetime] NULL,
[service_period_to] [datetime] NULL,
[Max_service_period_from] [datetime] NULL,
[Max_service_period_to] [datetime] NULL,
[LTDPayment] [decimal] (38, 2) NULL,
[Refunds] [int] NULL,
[Payments] [int] NULL,
[Status] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActiveSubscriber] [int] NOT NULL,
[DMLastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
