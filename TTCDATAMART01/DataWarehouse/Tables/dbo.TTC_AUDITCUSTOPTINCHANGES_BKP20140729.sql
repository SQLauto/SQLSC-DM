CREATE TABLE [dbo].[TTC_AUDITCUSTOPTINCHANGES_BKP20140729]
(
[ACTIONREQUESTED] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPTINID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CUSTACCOUNT] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MODIFIEDDATETIME] [datetime] NOT NULL,
[MODIFIEDBY] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CREATEDDATETIME] [datetime] NOT NULL,
[CREATEDBY] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DATAAREAID] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RECVERSION] [int] NOT NULL,
[RECID] [bigint] NOT NULL
) ON [PRIMARY]
GO
