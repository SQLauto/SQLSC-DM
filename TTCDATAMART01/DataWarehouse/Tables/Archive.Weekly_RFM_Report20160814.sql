CREATE TABLE [Archive].[Weekly_RFM_Report20160814]
(
[SeqNum] [tinyint] NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mf] [int] NULL,
[CollegeCustCount] [int] NULL,
[PublicLibraryCount] [int] NULL,
[TotalCount] [int] NULL,
[FinalCount] [int] NULL,
[ReportFor] [datetime] NULL,
[ReportGenerated] [datetime] NULL,
[CA_CollegeCustCount] [int] NULL,
[CA_PublicLibraryCount] [int] NULL,
[CA_TotalCount] [int] NULL,
[CA_FinalCount] [int] NULL,
[GB_FinalCount] [int] NULL,
[AU_FinalCount] [int] NULL
) ON [PRIMARY]
GO
