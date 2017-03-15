CREATE TABLE [Mapping].[Customer_modelScore_del]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModelScore] [float] NULL,
[DMUpdateddate] [datetime] NULL CONSTRAINT [DF__Customer___DMUpd__6F720655] DEFAULT (getdate())
) ON [PRIMARY]
GO
