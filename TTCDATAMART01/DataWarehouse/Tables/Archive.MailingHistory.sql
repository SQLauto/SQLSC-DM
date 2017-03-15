CREATE TABLE [Archive].[MailingHistory]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdCode] [int] NOT NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[Concatenated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagHoldOut] [smallint] NULL CONSTRAINT [DF_MailingHistory_FlagHoldOut] DEFAULT ((0)),
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjRank] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [date] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idxMailingHistory_CustomerID_AdCode] ON [Archive].[MailingHistory] ([CustomerID], [AdCode]) ON [PRIMARY]
GO
