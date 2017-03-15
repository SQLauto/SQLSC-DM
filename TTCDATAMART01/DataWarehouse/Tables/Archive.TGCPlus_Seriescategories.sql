CREATE TABLE [Archive].[TGCPlus_Seriescategories]
(
[series_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[series_categories_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordinal_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[category_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastUpdateESTDateTime] [datetime] NOT NULL CONSTRAINT [DF__TGCPlus_S__DMLas__169529C0] DEFAULT (getdate())
) ON [PRIMARY]
GO
