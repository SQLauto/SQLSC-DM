CREATE TABLE [Staging].[epc_splitter]
(
[adcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_adcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comboid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[preferredcategory] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[split_percentage] [int] NULL,
[Cnt] [int] NULL,
[processed] [bit] NULL
) ON [PRIMARY]
GO
