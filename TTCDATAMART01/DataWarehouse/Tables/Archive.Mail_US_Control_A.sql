CREATE TABLE [Archive].[Mail_US_Control_A]
(
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdCode] [numeric] (14, 0) NULL,
[NewSeg] [numeric] (14, 0) NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [numeric] (14, 0) NULL,
[Concatenated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagHoldOut] [numeric] (13, 0) NULL,
[SubjRank] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SelectionProb] [float] NULL,
[SamplingWeight] [float] NULL
) ON [PRIMARY]
GO
