CREATE TABLE [Archive].[DAXImportTableQC]
(
[table_name] [sys].[sysname] NOT NULL,
[row_count] [int] NULL,
[col_count] [int] NULL,
[data_size] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [datetime] NOT NULL,
[row_count_diff] [int] NULL,
[new_table_flag] [bit] NULL,
[LastReportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
