CREATE TABLE [Archive].[FIG00FIGHistory_FIGID]
(
[Customerid] [int] NOT NULL,
[FROMCOURSEID] [float] NULL,
[SendDate] [smalldatetime] NULL,
[FIGID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdCode] [int] NULL,
[EmailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
