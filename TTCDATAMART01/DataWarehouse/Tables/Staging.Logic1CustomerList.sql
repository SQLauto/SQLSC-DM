CREATE TABLE [Staging].[Logic1CustomerList]
(
[CustomerID] [int] NOT NULL,
[ListId] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic1CustomerList] ADD CONSTRAINT [UC_Logic1CustomerList] UNIQUE NONCLUSTERED  ([CustomerID], [ListId]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic1CustomerList] ADD CONSTRAINT [FK_Logic1CustomerList_ListID] FOREIGN KEY ([ListId]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
