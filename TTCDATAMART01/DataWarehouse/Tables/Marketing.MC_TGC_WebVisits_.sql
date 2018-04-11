CREATE TABLE [Marketing].[MC_TGC_WebVisits_]
(
[MC_TGC_WebVisits_id] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MonthStartDate] [date] NULL,
[AllVisits] [int] NULL,
[ProdViews] [int] NULL,
[PageViews] [int] NULL,
[DMLastupdated] [datetime] NOT NULL CONSTRAINT [DF__MC_TGC_We__DMLas__39F5A0A2] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Marketing].[MC_TGC_WebVisits_] ADD CONSTRAINT [PK__MC_TGC_W__CB4F4E2190211A30] PRIMARY KEY CLUSTERED  ([MC_TGC_WebVisits_id]) ON [PRIMARY]
GO
