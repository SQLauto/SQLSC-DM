CREATE TABLE [Mapping].[MailHistoryPMCountrySubjectAdcode]
(
[MailHistoryPMCountrySubjectAdcodeID] [int] NOT NULL IDENTITY(1, 1),
[CountryCd] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableNm] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Directory] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectFlag] [bit] NULL CONSTRAINT [DF__MailHisto__Subje__134B499B] DEFAULT ((0)),
[PMUpdateflag] [bit] NULL CONSTRAINT [DF__MailHisto__PMUpd__143F6DD4] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MailHistoryPMCountrySubjectAdcode] ADD CONSTRAINT [PK__MailHist__E4329D6D11630129] PRIMARY KEY CLUSTERED  ([MailHistoryPMCountrySubjectAdcodeID]) ON [PRIMARY]
GO
