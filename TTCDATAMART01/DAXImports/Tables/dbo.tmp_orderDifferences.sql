CREATE TABLE [dbo].[tmp_orderDifferences]
(
[salesid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DAXTotal] [numeric] (38, 6) NULL,
[Orderdate] [datetime] NOT NULL,
[TotalMerchandise] [money] NULL
) ON [PRIMARY]
GO
