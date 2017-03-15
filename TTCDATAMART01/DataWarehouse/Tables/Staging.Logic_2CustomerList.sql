CREATE TABLE [Staging].[Logic_2CustomerList]
(
[CustomerID] [int] NOT NULL,
[ListId] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic_2CustomerList] ADD CONSTRAINT [UC_Logic_2CustomerList] UNIQUE NONCLUSTERED  ([CustomerID], [ListId]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic_2CustomerList] ADD CONSTRAINT [FK_Logic_2CustomerList_ListID] FOREIGN KEY ([ListId]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
