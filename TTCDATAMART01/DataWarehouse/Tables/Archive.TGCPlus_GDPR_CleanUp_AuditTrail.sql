CREATE TABLE [Archive].[TGCPlus_GDPR_CleanUp_AuditTrail]
(
[TableName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userId] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customerid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailaddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userFirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userLastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[line1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[line2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[line3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMlastUpdated] [datetime] NULL CONSTRAINT [DF__TGCPlus_G__DMlas__4F4C1DFB] DEFAULT (getdate())
) ON [PRIMARY]
GO
