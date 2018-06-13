CREATE TABLE [Marketing].[MC_CustomerPreference_R3]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfDate] [date] NULL,
[SubjectCatR3] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectPrefR3] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecondarySubjPrefR3] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMediaCatR3] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMediaPrefR3] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAVCatR3] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAVPrefR3] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatPDCatR3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatPDPrefR3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourceCatR3] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourcePrefR3] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelRUPrefR3] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
