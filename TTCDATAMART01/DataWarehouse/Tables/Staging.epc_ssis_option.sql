CREATE TABLE [Staging].[epc_ssis_option]
(
[option_id] [int] NOT NULL,
[name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdatedDate] [datetime] NOT NULL CONSTRAINT [DF__epc_ssis___DMLas__39E1618F] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Staging].[epc_ssis_option] ADD CONSTRAINT [PK__epc_ssis__F4EACE1B37F9191D] PRIMARY KEY CLUSTERED  ([option_id]) ON [PRIMARY]
GO
