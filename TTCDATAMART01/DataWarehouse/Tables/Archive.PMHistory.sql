CREATE TABLE [Archive].[PMHistory]
(
[MailHistoryPMCountrySubjectAdcodeID] [int] NOT NULL,
[TableNm] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adcode] [int] NULL,
[InitialCnts] [int] NULL,
[PMAdcode] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PMCnts] [int] NULL,
[HistoryCnts] [int] NULL,
[Updateddate] [datetime] NOT NULL
) ON [PRIMARY]
GO
