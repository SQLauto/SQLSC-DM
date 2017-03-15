CREATE TABLE [Archive].[DM_CCS_QC]
(
[AsofDate] [datetime] NOT NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalCust] [int] NULL,
[TotalUniqCust] [int] NULL
) ON [PRIMARY]
GO
