CREATE TABLE [Staging].[Logic2CustomerList]
(
[CustomerID] [int] NOT NULL,
[ListId] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic2CustomerList] ADD CONSTRAINT [UC_Logic2CustomerID] UNIQUE NONCLUSTERED  ([CustomerID]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic2CustomerList] ADD CONSTRAINT [FK_Logic2CustomerList_ListID] FOREIGN KEY ([ListId]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
