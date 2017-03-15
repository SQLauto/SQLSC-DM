CREATE TABLE [dbo].[DMCheckTotals20140520]
(
[salesid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LineNumber] [int] NULL,
[Realpricing] [int] NULL,
[RealTotal] [numeric] (38, 6) NULL,
[BOMPrice] [int] NULL,
[BOMTotal] [numeric] (38, 6) NULL,
[RollupLines] [int] NULL,
[RealLines] [int] NULL
) ON [PRIMARY]
GO
