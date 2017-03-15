CREATE TABLE [Staging].[Logic0CustomerList]
(
[CustomerID] [int] NOT NULL,
[ListId] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic0CustomerList] ADD CONSTRAINT [UC_Logic0CustomerList] UNIQUE NONCLUSTERED  ([CustomerID], [ListId]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic0CustomerList] ADD CONSTRAINT [FK_Logic0CustomerList_ListID] FOREIGN KEY ([ListId]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
