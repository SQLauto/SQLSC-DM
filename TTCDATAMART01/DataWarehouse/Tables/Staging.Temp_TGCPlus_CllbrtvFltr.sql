CREATE TABLE [Staging].[Temp_TGCPlus_CllbrtvFltr]
(
[UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lectureRunTime] [bigint] NULL,
[PctStreamedMins] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StreamedMins] [numeric] (12, 1) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
