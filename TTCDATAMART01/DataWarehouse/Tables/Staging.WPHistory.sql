CREATE TABLE [Staging].[WPHistory]
(
[CustomerID] [int] NULL,
[PullDate] [smalldatetime] NULL,
[StartDate] [smalldatetime] NULL,
[EndDate] [smalldatetime] NULL,
[RFM] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[New Seg] [int] NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mF] [int] NULL,
[Group] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ByrType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropDate] [smalldatetime] NULL,
[TestGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupCat] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [int] NULL
) ON [PRIMARY]
GO
