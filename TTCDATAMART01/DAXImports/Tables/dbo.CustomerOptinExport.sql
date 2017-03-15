CREATE TABLE [dbo].[CustomerOptinExport]
(
[customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Optinid] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_OptinCustomerid] ON [dbo].[CustomerOptinExport] ([customerid]) ON [PRIMARY]
GO
