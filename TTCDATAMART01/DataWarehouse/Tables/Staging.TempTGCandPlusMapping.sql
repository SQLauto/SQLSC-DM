CREATE TABLE [Staging].[TempTGCandPlusMapping]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[LastOrderDate] [datetime] NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaFormatPreference] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [date] NULL,
[EndDate] [date] NULL,
[AsOfDate] [date] NULL,
[TGCPlusCustID] [bigint] NULL,
[TGCPlusCustStatusFlag] [float] NULL,
[TGCPlusSubDate] [date] NULL,
[TGCPlusSubPlanID] [int] NULL,
[TGCPlusSubPlanName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCPlusSubType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
