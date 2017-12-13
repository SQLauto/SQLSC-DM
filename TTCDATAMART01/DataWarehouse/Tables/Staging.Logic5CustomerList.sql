CREATE TABLE [Staging].[Logic5CustomerList]
(
[CustomerID] [int] NOT NULL,
[ListId] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic5CustomerList] ADD CONSTRAINT [UC_Logic5CustomerID] UNIQUE NONCLUSTERED  ([CustomerID]) ON [PRIMARY]
GO
ALTER TABLE [Staging].[Logic5CustomerList] ADD CONSTRAINT [FK_Logic5CustomerList_ListID] FOREIGN KEY ([ListId]) REFERENCES [Mapping].[TGC_Upsell_Logic_List] ([ListID])
GO
