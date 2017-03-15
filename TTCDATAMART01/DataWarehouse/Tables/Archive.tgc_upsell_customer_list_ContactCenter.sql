CREATE TABLE [Archive].[tgc_upsell_customer_list_ContactCenter]
(
[dax_customer_id] [int] NOT NULL,
[location_id] [tinyint] NOT NULL,
[test_rank] [tinyint] NOT NULL,
[list_id] [smallint] NOT NULL,
[Last_Updated_Date] [datetime] NOT NULL CONSTRAINT [DF_tgc_upsell_customer_list_ContactCenter_Last_Updated_Date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[tgc_upsell_customer_list_ContactCenter] ADD CONSTRAINT [PK__tgc_upse__372D73423D05A173] PRIMARY KEY CLUSTERED  ([dax_customer_id]) ON [PRIMARY]
GO
ALTER TABLE [Archive].[tgc_upsell_customer_list_ContactCenter] ADD CONSTRAINT [UC_tgc_upsell_customer_list_ContactCenter] UNIQUE NONCLUSTERED  ([dax_customer_id], [location_id], [test_rank]) ON [PRIMARY]
GO
