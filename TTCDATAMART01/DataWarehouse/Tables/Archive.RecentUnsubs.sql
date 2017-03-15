CREATE TABLE [Archive].[RecentUnsubs]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfDate] [date] NULL,
[FlagEmail] [bit] NULL,
[FlagValidEmail] [bit] NULL,
[FlagEmailPref] [bit] NULL,
[FlagMail] [bit] NULL,
[FlagMailPref] [bit] NULL,
[FlagNonBlankMailAddress] [bit] NULL,
[EmailAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
