CREATE TABLE [Staging].[MC_TGC_ContactPreference]
(
[Asofdate] [date] NULL,
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagEmailPref] [tinyint] NULL,
[FlagEmailValid] [tinyint] NULL,
[FlagEmailable] [tinyint] NULL,
[FlagMailPref] [tinyint] NULL,
[FlagMail] [tinyint] NULL
) ON [PRIMARY]
GO
