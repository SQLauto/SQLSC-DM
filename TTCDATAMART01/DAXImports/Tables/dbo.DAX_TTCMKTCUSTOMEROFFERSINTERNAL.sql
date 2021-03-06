CREATE TABLE [dbo].[DAX_TTCMKTCUSTOMEROFFERSINTERNAL]
(
[ACCOUNTNUM] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DAX_TTCMK__ACCOU__2A4B4B5E] DEFAULT (''),
[SPLITNAME] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DAX_TTCMK__SPLIT__2B3F6F97] DEFAULT (''),
[SPLITASSIGNED] [int] NOT NULL CONSTRAINT [DF__DAX_TTCMK__SPLIT__2C3393D0] DEFAULT ((0)),
[MODIFIEDDATETIME] [datetime] NOT NULL CONSTRAINT [DF__DAX_TTCMK__MODIF__2D27B809] DEFAULT (dateadd(millisecond,-datepart(millisecond,getutcdate()),getutcdate())),
[MODIFIEDBY] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DAX_TTCMK__MODIF__2E1BDC42] DEFAULT ('?'),
[CREATEDDATETIME] [datetime] NOT NULL CONSTRAINT [DF__DAX_TTCMK__CREAT__2F10007B] DEFAULT (dateadd(millisecond,-datepart(millisecond,getutcdate()),getutcdate())),
[CREATEDBY] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DAX_TTCMK__CREAT__300424B4] DEFAULT ('?'),
[RECVERSION] [int] NOT NULL CONSTRAINT [DF__DAX_TTCMK__RECVE__30F848ED] DEFAULT ((1)),
[RECID] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DAX_TTCMKTCUSTOMEROFFERSINTERNAL] ADD CONSTRAINT [CK__DAX_TTCMK__RECID__31EC6D26] CHECK (([RECID]<>(0)))
GO
ALTER TABLE [dbo].[DAX_TTCMKTCUSTOMEROFFERSINTERNAL] ADD CONSTRAINT [I_40130ACCOUNTNUMIDX] PRIMARY KEY CLUSTERED  ([ACCOUNTNUM], [SPLITNAME]) ON [PRIMARY]
GO
