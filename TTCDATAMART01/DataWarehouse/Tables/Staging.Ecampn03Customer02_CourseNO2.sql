CREATE TABLE [Staging].[Ecampn03Customer02_CourseNO2]
(
[Customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NOT NULL,
[Rank] [float] NULL,
[Adcode] [int] NULL,
[Region] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectLine] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EcampaignID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rank2] [bigint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_Ecampn03Customer02_CourseNO21] ON [Staging].[Ecampn03Customer02_CourseNO2] ([Customerid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_Ecampn03Customer02_CourseNO22] ON [Staging].[Ecampn03Customer02_CourseNO2] ([Rank2]) ON [PRIMARY]
GO
