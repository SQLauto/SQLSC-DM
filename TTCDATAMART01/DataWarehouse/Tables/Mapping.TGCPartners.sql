CREATE TABLE [Mapping].[TGCPartners]
(
[PartnerID] [smallint] NOT NULL IDENTITY(1, 1),
[PartnerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AbbrvPartnerName] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[TGCPartners] ADD CONSTRAINT [pk_TGCPartner] PRIMARY KEY CLUSTERED  ([PartnerID]) ON [PRIMARY]
GO
