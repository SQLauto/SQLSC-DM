CREATE TABLE [dbo].[epc_preference_option]
(
[preference_option_id] [int] NOT NULL,
[preference_id] [int] NULL,
[option_id] [int] NULL,
[frequency_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[epc_preference_option] ADD CONSTRAINT [PK__epc_pref__559C514E4D5F7D71] PRIMARY KEY CLUSTERED  ([preference_option_id]) ON [PRIMARY]
GO
