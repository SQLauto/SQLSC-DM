CREATE TABLE [Mapping].[TGC_Upsell_Logic]
(
[LogicID] [smallint] NOT NULL IDENTITY(1, 1),
[LogicName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogicDescription] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagActive] [bit] NOT NULL CONSTRAINT [DF__TGC_Upsel__FlagA__522729F1] DEFAULT ((0)),
[StoredProc] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerListTable] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RankTable] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF__TGC_Upsel__Creat__531B4E2A] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[TGC_Upsell_Logic] ADD CONSTRAINT [PK_TGC_Upsell_Logic] PRIMARY KEY CLUSTERED  ([LogicID]) ON [PRIMARY]
GO
