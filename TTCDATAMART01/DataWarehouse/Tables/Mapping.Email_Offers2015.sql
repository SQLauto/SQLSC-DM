CREATE TABLE [Mapping].[Email_Offers2015]
(
[EmailOfferID] [float] NULL,
[EmailOffer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UNKey_Email_Offers2015] ON [Mapping].[Email_Offers2015] ([EmailOfferID]) ON [PRIMARY]
GO
