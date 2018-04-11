CREATE TABLE [Archive].[TGCPlus_SailThru_blast_Streaming]
(
[TGCPlus_SailThru_blast_Streaming_id] [bigint] NOT NULL IDENTITY(1, 1),
[UUID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customerid] [bigint] NULL,
[profile_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blast_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[send_date] [date] NULL,
[Prior3DayStreamedMins] [numeric] (38, 1) NULL,
[Prior2DayStreamedMins] [numeric] (38, 1) NULL,
[Prior1DayStreamedMins] [numeric] (38, 1) NULL,
[CurrentDayStreamedMins] [numeric] (38, 1) NULL,
[Post1DayStreamedMins] [numeric] (38, 1) NULL,
[Post2DayStreamedMins] [numeric] (38, 1) NULL,
[Post3DayStreamedMins] [numeric] (38, 1) NULL,
[Prior3DayCoursesStreamed] [int] NULL,
[Prior2DayCoursesStreamed] [int] NULL,
[Prior1DayCoursesStreamed] [int] NULL,
[CurrentDayCoursesStreamed] [int] NULL,
[Post1DayCoursesStreamed] [int] NULL,
[Post2DayCoursesStreamed] [int] NULL,
[Post3DayCoursesStreamed] [int] NULL,
[Prior3DayLecturesStreamed] [int] NULL,
[Prior2DayLecturesStreamed] [int] NULL,
[Prior1DayLecturesStreamed] [int] NULL,
[CurrentDayLecturesStreamed] [int] NULL,
[Post1DayLecturesStreamed] [int] NULL,
[Post2DayLecturesStreamed] [int] NULL,
[Post3DayLecturesStreamed] [int] NULL,
[IntlSubType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustStatusFlag] [float] NULL,
[PaidFlag] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__TGCPlus_S__DMLas__490F5DAE] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[TGCPlus_SailThru_blast_Streaming] ADD CONSTRAINT [PK__TGCPlus___79498E38A7BCC878] PRIMARY KEY CLUSTERED  ([TGCPlus_SailThru_blast_Streaming_id]) ON [PRIMARY]
GO
