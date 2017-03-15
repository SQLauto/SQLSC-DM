CREATE TABLE [Staging].[TGCPlus_Customer]
(
[AsofDate] [date] NULL,
[CustomerID] [bigint] NULL,
[pas_id] [bigint] NOT NULL,
[SubPlanID] [bigint] NULL,
[pas_state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas_created_at] [datetime] NULL,
[pas_payment_handler] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prior_pas_state] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prior_pas_Plan_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prior_pas_payment_handler] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeqNum] [bigint] NULL
) ON [PRIMARY]
GO
