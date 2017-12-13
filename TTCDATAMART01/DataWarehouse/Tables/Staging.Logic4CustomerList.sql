CREATE TABLE [Staging].[Logic4CustomerList]
(
[CustomerID] [int] NOT NULL,
[ListId] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic4CustomerList] ADD CONSTRAINT [UC_Logic4CustomerID] UNIQUE NONCLUSTERED  ([CustomerID]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic4CustomerList] ADD CONSTRAINT [FK_Logic4CustomerList_ListID] FOREIGN KEY ([ListId]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
