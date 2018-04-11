CREATE TABLE [Marketing].[MC_TGC_WebVisits]
(
[MC_TGC_WebVisits_id] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MonthStartDate] [date] NULL,
[AllVisits] [int] NULL,
[ProdViews] [int] NULL,
[PageViews] [int] NULL,
[DMLastupdated] [datetime] NOT NULL CONSTRAINT [DF__MC_TGC_We__DMLas__2F78122F] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[MC_TGC_WebVisits] ADD CONSTRAINT [PK__MC_TGC_W__CB4F4E21CFABB2A2] PRIMARY KEY CLUSTERED  ([MC_TGC_WebVisits_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UC_MC_TGC_WebVisits] ON [Marketing].[MC_TGC_WebVisits] ([CustomerID], [MonthStartDate]) ON [PRIMARY]
GO
