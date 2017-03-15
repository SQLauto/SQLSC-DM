CREATE TABLE [staging].[DAX_OrderPaymentsExport]
(
[Orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LINENUM] [numeric] (28, 12) NOT NULL,
[Recid] [bigint] NOT NULL,
[PaymMode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status] [int] NOT NULL,
[ccvendor] [int] NOT NULL,
[CURRENCYCODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AMOUNT] [numeric] (28, 12) NOT NULL,
[CheckNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpirationMonth] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpirationYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [staging].[DAX_OrderPaymentsExport] ADD CONSTRAINT [PK_DAX_OrderPaymentsExport] PRIMARY KEY CLUSTERED  ([Orderid], [LINENUM], [Recid]) ON [PRIMARY]
GO
