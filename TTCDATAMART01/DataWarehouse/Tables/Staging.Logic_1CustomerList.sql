CREATE TABLE [Staging].[Logic_1CustomerList]
(
[CustomerID] [int] NOT NULL,
[ListId] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic_1CustomerList] ADD CONSTRAINT [UC_Logic_1CustomerList] UNIQUE NONCLUSTERED  ([CustomerID], [ListId]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic_1CustomerList] ADD CONSTRAINT [FK_Logic_1CustomerList_ListID] FOREIGN KEY ([ListId]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
