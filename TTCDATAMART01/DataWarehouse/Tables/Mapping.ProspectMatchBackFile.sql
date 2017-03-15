CREATE TABLE [Mapping].[ProspectMatchBackFile]
(
[OSWYear] [int] NOT NULL,
[OSWType] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [int] NULL,
[MailedAdcode] [int] NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NULL,
[StopDate] [datetime] NULL,
[TableName] [varchar] (52) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
