CREATE TABLE [Staging].[epc_ssis_preference_option]
(
[preference_option_id] [int] NOT NULL,
[preference_id] [int] NULL,
[option_id] [int] NULL,
[frequency_id] [int] NULL,
[DMLastupdatedDate] [datetime] NOT NULL CONSTRAINT [DF__epc_ssis___DMLas__482F80E6] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[epc_ssis_preference_option] ADD CONSTRAINT [PK__epc_ssis__559C514E46473874] PRIMARY KEY CLUSTERED  ([preference_option_id]) ON [PRIMARY]
GO
