CREATE TABLE [Staging].[epc_Reinstated_Email]
(
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lastupdateddatetime] [datetime] NULL CONSTRAINT [DF__epc_Reins__Lastu__16B8EC3A] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [Pk_EPC_Reinstated_Email] ON [Staging].[epc_Reinstated_Email] ([Email]) ON [PRIMARY]
GO
