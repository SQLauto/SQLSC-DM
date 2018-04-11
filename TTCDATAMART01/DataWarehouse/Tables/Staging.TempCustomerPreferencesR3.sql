CREATE TABLE [Staging].[TempCustomerPreferencesR3]
(
[AsOfDate] [smalldatetime] NOT NULL,
[SubjectCatR3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubjectCat] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectPref] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecondarySubjPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMediaCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAVCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatADCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourceCat] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
