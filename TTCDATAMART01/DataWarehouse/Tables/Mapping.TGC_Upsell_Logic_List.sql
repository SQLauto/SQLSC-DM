CREATE TABLE [Mapping].[TGC_Upsell_Logic_List]
(
[LogicID] [smallint] NOT NULL,
[ListID] [smallint] NOT NULL IDENTITY(1, 1),
[ListName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DMLastUpdated] [datetime] NOT NULL CONSTRAINT [DF__TGC_Upsel__DMLas__55F7BAD5] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[TGC_Upsell_Logic_List] ADD CONSTRAINT [PK_TGC_Upsell_Logic_List_ListID] PRIMARY KEY CLUSTERED  ([ListID]) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[TGC_Upsell_Logic_List] ADD CONSTRAINT [UC_TGC_Upsell_Logic_List] UNIQUE NONCLUSTERED  ([LogicID], [ListName]) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[TGC_Upsell_Logic_List] ADD CONSTRAINT [FK_TGC_Upsell_Logic_List_LogicID] FOREIGN KEY ([LogicID]) REFERENCES [Mapping].[TGC_Upsell_Logic] ([LogicID])
GO
