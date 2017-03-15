CREATE TABLE [Marketing].[Demographics_WD_YOY]
(
[AsofDate] [smalldatetime] NOT NULL,
[AsOfMonth] [tinyint] NOT NULL,
[AsOfYear] [smallint] NOT NULL,
[ActiveOrSwamp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewSeg] [tinyint] NOT NULL,
[Name] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[A12MF] [tinyint] NOT NULL,
[AgeBin_WD] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Income_WD] [varchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education_WD] [varchar] (27) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender_WD] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customersegment] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HHIncomeBin_WD] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[networth] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [datetime] NOT NULL,
[CustCount] [int] NULL
) ON [PRIMARY]
GO
