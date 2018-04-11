CREATE TABLE [Staging].[MC_TGC_EMailPreference]
(
[Customerid] [int] NOT NULL,
[AsOfDate] [smalldatetime] NOT NULL,
[FlagEmailable] [tinyint] NULL,
[FlagEmailPref] [tinyint] NULL,
[FlagEmailValid] [tinyint] NULL
) ON [PRIMARY]
GO
