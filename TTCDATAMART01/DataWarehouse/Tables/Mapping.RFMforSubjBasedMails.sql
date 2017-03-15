CREATE TABLE [Mapping].[RFMforSubjBasedMails]
(
[MailPiece] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerSegment] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubjRank] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagMail] [int] NULL
) ON [PRIMARY]
GO
