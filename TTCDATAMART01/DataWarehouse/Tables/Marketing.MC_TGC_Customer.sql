CREATE TABLE [Marketing].[MC_TGC_Customer]
(
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateAdded] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [PK_MC_TGC_Customer] ON [Marketing].[MC_TGC_Customer] ([Customerid]) ON [PRIMARY]
GO
