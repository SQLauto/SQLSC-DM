CREATE TABLE [dbo].[epc_option]
(
[option_id] [int] NOT NULL,
[name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frequency_supported] [smallint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[epc_option] ADD CONSTRAINT [PK__epc_opti__F4EACE1B7755B73D] PRIMARY KEY CLUSTERED  ([option_id]) ON [PRIMARY]
GO
