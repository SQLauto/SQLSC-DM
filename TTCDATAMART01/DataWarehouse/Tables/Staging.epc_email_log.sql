CREATE TABLE [Staging].[epc_email_log]
(
[epc_email_log_id] [int] NOT NULL IDENTITY(1, 1),
[EmailTable] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Priority] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailSendDate] [date] NULL,
[Processed] [bit] NULL CONSTRAINT [DF__epc_email__Proce__7108449E] DEFAULT ((0)),
[TransferredToCOLO] [bit] NULL CONSTRAINT [DF__epc_email__Trans__71FC68D7] DEFAULT ((0)),
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__epc_email__DMLas__72F08D10] DEFAULT (getdate())
) ON [PRIMARY]
GO
