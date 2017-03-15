CREATE TABLE [dbo].[epc_reason]
(
[reason_id] [int] NOT NULL,
[name] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[epc_reason] ADD CONSTRAINT [PK__epc_reas__846BB5546FB49575] PRIMARY KEY CLUSTERED  ([reason_id]) ON [PRIMARY]
GO
