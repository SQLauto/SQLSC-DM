CREATE TABLE [Mapping].[TGC_Upsell_Location]
(
[LocationID] [tinyint] NOT NULL,
[LocationName] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsCourseRequired] [bit] NOT NULL CONSTRAINT [DF__TGC_Upsel__IsCou__4F4ABD46] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[TGC_Upsell_Location] ADD CONSTRAINT [PK_TGC_Upsell_Location] PRIMARY KEY CLUSTERED  ([LocationID]) ON [PRIMARY]
GO
