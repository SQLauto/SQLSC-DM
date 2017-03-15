CREATE TABLE [Marketing].[Customer_3MonthChurn_Model]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModelScore] [float] NULL,
[Acquireddate] [datetime] NULL,
[DMUpdateddate] [datetime] NULL,
[Decile] [int] NULL,
[FlagEmail] [bit] NULL CONSTRAINT [DF__Customer___FlagE__39F838A0] DEFAULT ((0))
) ON [PRIMARY]
GO
