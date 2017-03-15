CREATE TABLE [Archive].[RFMHistory]
(
[CustomerID] [dbo].[udtCustomerID] NULL,
[RFM] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NULL,
[a12mF] [int] NULL,
[cnt_of_orderID] [int] NULL,
[ProcessingDate] [datetime] NULL,
[FlagDRTV] [bit] NULL
) ON [PRIMARY]
GO
