CREATE TABLE [staging].[DAX_TTCMKTCUSTOMEROFFERSINTERNAL]
(
[ACCOUNTNUM] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DAX_TTCMK__ACCOU__43D61337] DEFAULT (''),
[SPLITNAME] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DAX_TTCMK__SPLIT__44CA3770] DEFAULT (''),
[SPLITASSIGNED] [int] NOT NULL CONSTRAINT [DF__DAX_TTCMK__SPLIT__45BE5BA9] DEFAULT ((0)),
[MODIFIEDDATETIME] [datetime] NOT NULL CONSTRAINT [DF__DAX_TTCMK__MODIF__46B27FE2] DEFAULT (dateadd(millisecond,-datepart(millisecond,getutcdate()),getutcdate())),
[MODIFIEDBY] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DAX_TTCMK__MODIF__47A6A41B] DEFAULT ('?'),
[CREATEDDATETIME] [datetime] NOT NULL CONSTRAINT [DF__DAX_TTCMK__CREAT__489AC854] DEFAULT (dateadd(millisecond,-datepart(millisecond,getutcdate()),getutcdate())),
[CREATEDBY] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DAX_TTCMK__CREAT__498EEC8D] DEFAULT ('?'),
[RECVERSION] [int] NOT NULL CONSTRAINT [DF__DAX_TTCMK__RECVE__4A8310C6] DEFAULT ((1)),
[RECID] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [staging].[DAX_TTCMKTCUSTOMEROFFERSINTERNAL] ADD CONSTRAINT [CK__DAX_TTCMK__RECID__42E1EEFE] CHECK (([RECID]<>(0)))
GO
ALTER TABLE [staging].[DAX_TTCMKTCUSTOMEROFFERSINTERNAL] ADD CONSTRAINT [I_40130ACCOUNTNUMIDX] PRIMARY KEY CLUSTERED  ([ACCOUNTNUM], [SPLITNAME]) ON [PRIMARY]
GO
