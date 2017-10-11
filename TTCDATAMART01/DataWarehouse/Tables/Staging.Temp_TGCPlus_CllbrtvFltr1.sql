CREATE TABLE [Staging].[Temp_TGCPlus_CllbrtvFltr1]
(
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tstamp] [date] NULL,
[PctStreamedMins] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StreamedMins] [numeric] (38, 1) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
