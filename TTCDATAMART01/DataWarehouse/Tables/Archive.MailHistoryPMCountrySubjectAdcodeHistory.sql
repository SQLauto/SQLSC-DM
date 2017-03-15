CREATE TABLE [Archive].[MailHistoryPMCountrySubjectAdcodeHistory]
(
[MailHistoryPMCountrySubjectAdcodeID] [int] NOT NULL,
[TableNm] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[adcode] [int] NULL,
[InitialCnts] [int] NULL,
[PMadcode] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PMCnts] [int] NULL,
[Updateddate] [datetime] NOT NULL
) ON [PRIMARY]
GO
