CREATE TABLE [Mapping].[TGCPlus_DS]
(
[Customerid] [bigint] NULL,
[Min_service_period_From] [datetime] NULL,
[Min_service_period_to] [datetime] NULL,
[Max_service_period_to] [datetime] NULL,
[DSDate] [datetime] NULL,
[DS] [int] NULL,
[PriorDSDate] [datetime] NULL,
[DMLastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [UC_TGCPlus_DS_Customerid_DS] ON [Mapping].[TGCPlus_DS] ([Customerid], [DS]) ON [PRIMARY]
GO
