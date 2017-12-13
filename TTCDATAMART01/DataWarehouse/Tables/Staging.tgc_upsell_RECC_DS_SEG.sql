CREATE TABLE [Staging].[tgc_upsell_RECC_DS_SEG]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gender] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaFormatPreference] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourcePreference] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmail] [int] NULL,
[FlagMail] [int] NULL,
[ClickCnt] [int] NULL,
[age] [int] NULL,
[RecencyMonths] [int] NULL,
[LastSales] [money] NULL,
[Units] [int] NULL,
[Segment] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMlastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
