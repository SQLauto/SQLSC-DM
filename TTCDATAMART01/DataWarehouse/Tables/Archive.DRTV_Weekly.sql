CREATE TABLE [Archive].[DRTV_Weekly]
(
[Telemarketer] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TollFreeNum] [numeric] (10, 0) NOT NULL,
[Date] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MilitaryTime] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Response] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalCounts] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DNISCode] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZIP] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AreaCode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Output] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsertedDate] [datetime] NOT NULL CONSTRAINT [DF__DRTV_Week__Inser__1E5BA4B0] DEFAULT (getdate())
) ON [PRIMARY]
GO
