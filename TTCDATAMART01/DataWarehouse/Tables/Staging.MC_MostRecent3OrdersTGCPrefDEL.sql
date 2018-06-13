CREATE TABLE [Staging].[MC_MostRecent3OrdersTGCPrefDEL]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[Adcode] [int] NULL,
[MD_ChannelID] [int] NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelRU] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderItemID] [numeric] (28, 12) NULL,
[CourseID] [int] NULL,
[TotalParts] [money] NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMedia] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAV] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAD] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
