CREATE TABLE [Staging].[Ecampn03Customer02_CourseBundle]
(
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NOT NULL,
[Rank] [float] NULL,
[BundleFlag] [tinyint] NULL,
[Adcode] [int] NULL,
[Region] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectLine] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EcampaignID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Ecampn03Customer02_CourseBundle2] ON [Staging].[Ecampn03Customer02_CourseBundle] ([CourseID]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IDX_Ecampn03Customer02_CourseBundle] ON [Staging].[Ecampn03Customer02_CourseBundle] ([Customerid]) ON [PRIMARY]
GO
