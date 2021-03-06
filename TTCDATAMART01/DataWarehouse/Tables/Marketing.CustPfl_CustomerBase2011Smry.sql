CREATE TABLE [Marketing].[CustPfl_CustomerBase2011Smry]
(
[C_AsOfDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_AsOfYear] [int] NOT NULL,
[C_AsOfMonth] [int] NOT NULL,
[C_CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_FlagEmailable] [int] NULL,
[C_FLagMail] [int] NULL,
[C_R3SubjectPref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_R3OrderSourcePref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_R3FormatPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_eWGroup] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_LTDAvgOrderBin] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_DSLPurchBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Agebin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_Education] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_IncomeBin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_TenureBin] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_Region] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_FlagPrEmailOrder] [tinyint] NULL,
[C_FlagEngaged] [tinyint] NULL,
[O_FlagPurchFY] [tinyint] NULL,
[SalesIn2010Bin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagBoughtDigitlBfr] [int] NOT NULL,
[CouseCntIn2010Bin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustCount] [int] NULL,
[SalesFY] [money] NULL,
[OrdersFY] [int] NULL,
[CourseSalesFY] [int] NULL,
[UnitsFY] [int] NULL,
[PartsFY] [money] NULL,
[EmailContactsFY] [money] NULL,
[MailContactsFY] [int] NULL
) ON [PRIMARY]
GO
