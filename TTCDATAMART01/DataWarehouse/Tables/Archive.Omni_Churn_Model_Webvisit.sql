CREATE TABLE [Archive].[Omni_Churn_Model_Webvisit]
(
[Customerid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VisitDate] [datetime] NULL,
[Prodview] [int] NULL,
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__Omni_Chur__DMLas__6AAD5138] DEFAULT (getdate())
) ON [PRIMARY]
GO
