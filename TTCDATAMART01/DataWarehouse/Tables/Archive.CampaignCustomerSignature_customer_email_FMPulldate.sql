CREATE TABLE [Archive].[CampaignCustomerSignature_customer_email_FMPulldate]
(
[customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[emailaddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asofdate] [date] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CampaignCustomerSignature_customer_email_FMPulldate] ON [Archive].[CampaignCustomerSignature_customer_email_FMPulldate] ([customerid], [emailaddress], [asofdate]) ON [PRIMARY]
GO
