CREATE TABLE [dbo].[DAX_VendorOrderReference]
(
[TTCVENDACCOUNT] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TTCVENDKEYID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TTCSALESID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TTCORDERTOTAL] [numeric] (28, 12) NOT NULL,
[ImportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
