CREATE TABLE [Marketing].[TGCPlus_CllbrtvFilter_Customer_CourseReco]
(
[customerid] [bigint] NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinTstamp] [datetime] NULL,
[TSTAMP] [date] NULL,
[courseid] [bigint] NULL,
[SubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSDays] [int] NULL,
[CustStatusFlag] [float] NULL,
[IntlSubDate] [date] NULL,
[FlagStreamed] [int] NOT NULL,
[Reco_CourseID] [bigint] NULL,
[RecoRank] [bigint] NULL
) ON [PRIMARY]
GO
