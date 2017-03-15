CREATE TABLE [Mapping].[TGCplus_QC]
(
[TGCPlusTableName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrentCounts] [int] NULL,
[Previous1DaysCounts] [int] NULL,
[Previous2DaysCounts] [int] NULL,
[UpdatedPeviousCounts] [bit] NULL,
[UpdatedCurrentCounts] [bit] NULL,
[LastUpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[TGCplus_QC] ADD CONSTRAINT [PK__TGCplus___F0A2B9B180ADF1CF] PRIMARY KEY CLUSTERED  ([TGCPlusTableName]) ON [PRIMARY]
GO
