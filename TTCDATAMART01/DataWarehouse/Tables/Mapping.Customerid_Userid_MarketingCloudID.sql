CREATE TABLE [Mapping].[Customerid_Userid_MarketingCloudID]
(
[CustomerID] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[web_user_id] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarketingCloudVisitorID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
