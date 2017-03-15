CREATE TABLE [dbo].[MagentoCourseImports]
(
[pkey] [int] NOT NULL IDENTITY(1, 1),
[xmlFileName] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[xml_data] [xml] NOT NULL,
[CreateDate] [datetime] NOT NULL,
[ImportStatus] [int] NOT NULL CONSTRAINT [DF_Table_1_ImportComplete] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MagentoCourseImports] ADD CONSTRAINT [PK_MagentoCourseImports] PRIMARY KEY CLUSTERED  ([pkey], [ImportStatus]) ON [PRIMARY]
GO
