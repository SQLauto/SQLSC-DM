CREATE TABLE [Mapping].[RFMForCatalogs]
(
[MailPiece] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SeqNum] [int] NULL,
[RFMCells] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ComboID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [tinyint] NULL,
[January] [tinyint] NULL,
[February] [tinyint] NULL,
[March] [tinyint] NULL,
[April] [tinyint] NULL,
[May] [tinyint] NULL,
[June] [tinyint] NULL,
[July] [tinyint] NULL,
[August] [tinyint] NULL,
[September] [tinyint] NULL,
[October] [tinyint] NULL,
[OctoberBB] [tinyint] NULL,
[November] [tinyint] NULL,
[December] [tinyint] NULL,
[Holiday1] [tinyint] NULL,
[Holiday2] [tinyint] NULL,
[Holiday3] [tinyint] NULL,
[Yulalog] [tinyint] NULL,
[NewCourse] [tinyint] NULL,
[DefaultList] [tinyint] NULL
) ON [PRIMARY]
GO
