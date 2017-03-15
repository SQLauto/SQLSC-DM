CREATE TABLE [Marketing].[ForecastAssumptions_Customers]
(
[customerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPurchaseDate] [datetime] NOT NULL,
[RFMStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewOrExisting] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
