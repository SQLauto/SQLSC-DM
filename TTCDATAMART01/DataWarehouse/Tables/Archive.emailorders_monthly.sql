CREATE TABLE [Archive].[emailorders_monthly]
(
[emailorders_monthly] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OpenCnt] [int] NULL,
[ClickCnt] [int] NULL,
[EOMStartdate] [date] NULL,
[DMlastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[emailorders_monthly] ADD CONSTRAINT [PK__emailord__662D726210F5E8FB] PRIMARY KEY CLUSTERED  ([emailorders_monthly]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_emailorders_monthly_EOMStartdate] ON [Archive].[emailorders_monthly] ([EOMStartdate]) ON [PRIMARY]
GO
