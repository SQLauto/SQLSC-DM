CREATE TABLE [Mapping].[MktDim_Channel]
(
[MD_ChannelID] [int] NOT NULL IDENTITY(1, 1),
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Channel_Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagActive] [tinyint] NULL CONSTRAINT [DF__MktDim_Ch__FlagA__02AB98D5] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_Channel] ADD CONSTRAINT [pk_Channel_cid] PRIMARY KEY CLUSTERED  ([MD_ChannelID]) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_Channel] ADD CONSTRAINT [uc_MktDimChannel_Channel] UNIQUE NONCLUSTERED  ([MD_Channel], [MD_Channel_Description]) ON [PRIMARY]
GO
