CREATE TABLE [Staging].[Logic_3CustomerList]
(
[CustomerID] [int] NOT NULL,
[ListId] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic_3CustomerList] ADD CONSTRAINT [UC_Logic_3CustomerList] UNIQUE NONCLUSTERED  ([CustomerID], [ListId]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic_3CustomerList] ADD CONSTRAINT [FK_Logic_3CustomerList_ListID] FOREIGN KEY ([ListId]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
