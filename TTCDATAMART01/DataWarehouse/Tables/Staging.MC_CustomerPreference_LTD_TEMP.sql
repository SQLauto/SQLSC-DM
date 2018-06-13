CREATE TABLE [Staging].[MC_CustomerPreference_LTD_TEMP]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfDate] [date] NULL,
[SubjectCatLTD] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectPrefLTD] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecondarySubjPrefLTD] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMediaCatLTD] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMediaPrefLTD] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMediaLstLTD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAVPrefLTD] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAVLstLTD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatPDPrefLTD] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatPDLstLTD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourceCatLTD] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourcePrefLTD] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourceLstLTD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelRUCatLTD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelRUPrefLTD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelRULstLTD] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
