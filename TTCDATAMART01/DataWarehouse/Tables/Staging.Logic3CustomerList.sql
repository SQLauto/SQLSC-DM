CREATE TABLE [Staging].[Logic3CustomerList]
(
[CustomerID] [int] NOT NULL,
[ListId] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic3CustomerList] ADD CONSTRAINT [UC_Logic3CustomerID] UNIQUE NONCLUSTERED  ([CustomerID]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic3CustomerList] ADD CONSTRAINT [FK_Logic3CustomerList_ListID] FOREIGN KEY ([ListId]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
