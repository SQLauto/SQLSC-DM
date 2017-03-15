CREATE TABLE [Mapping].[CouponMeasures]
(
[Cpn_Code] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cpn_ID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cpn_Offer] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cpn_Campaign] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cpn_StartDate] [datetime] NULL,
[Cpn_EndDate] [datetime] NULL,
[Cpn_FinalEndDate] [datetime] NULL,
[Cpn_Measure1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cpn_Amount1] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cpn_Threshold1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cpn_ThresholdMeasure1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cpn_Measure2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cpn_Amount2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
