CREATE TABLE [Archive].[Email_DormantCustomer_Holdout_20170816]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Adcode] [int] NOT NULL,
[StartDate] [date] NULL,
[FlagHoldOut] [int] NOT NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DMlastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
