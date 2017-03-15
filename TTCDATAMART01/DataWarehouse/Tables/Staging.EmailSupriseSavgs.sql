CREATE TABLE [Staging].[EmailSupriseSavgs]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[adcode] [int] NOT NULL,
[PreferredCategory] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
