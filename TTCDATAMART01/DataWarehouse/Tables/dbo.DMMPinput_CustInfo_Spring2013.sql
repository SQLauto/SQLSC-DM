CREATE TABLE [dbo].[DMMPinput_CustInfo_Spring2013]
(
[CustomerID] [int] NULL,
[DwellType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumHits] [int] NULL,
[Gender] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ABCScore] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_DMMPinput_CustInfo_Spring2012] ON [dbo].[DMMPinput_CustInfo_Spring2013] ([CustomerID]) ON [PRIMARY]
GO
