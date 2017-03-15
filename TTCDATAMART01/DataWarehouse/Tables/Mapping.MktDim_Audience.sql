CREATE TABLE [Mapping].[MktDim_Audience]
(
[MD_AudienceID] [int] NOT NULL IDENTITY(1, 1),
[MD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Audience_Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagActive] [tinyint] NULL CONSTRAINT [DF__MktDim_Au__FlagA__0D292748] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_Audience] ADD CONSTRAINT [pk_MktDimAudience_aid] PRIMARY KEY CLUSTERED  ([MD_AudienceID]) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_Audience] ADD CONSTRAINT [uc_MktDimAudience_Audience] UNIQUE NONCLUSTERED  ([MD_Audience], [MD_Audience_Description]) ON [PRIMARY]
GO
