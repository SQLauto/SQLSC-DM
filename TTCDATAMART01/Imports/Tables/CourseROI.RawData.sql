CREATE TABLE [CourseROI].[RawData]
(
[CourseID] [float] NULL,
[CourseName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleaseDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parts] [float] NULL,
[SubCat2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Direct] [money] NULL,
[TGC Physical] [money] NULL,
[TGC Digital] [money] NULL,
[Audible] [money] NULL,
[Plus] [money] NULL,
[Total Revenue] [money] NULL,
[PD Cost] [money] NULL,
[Rev-PD Cost] [money] NULL,
[Blank] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Total Contribution] [money] NULL,
[Profit] [money] NULL,
[1yr ROI] [float] NULL,
[LastUpdateDate] [datetime] NULL,
[Physical Contribution] [money] NULL,
[Digital Contribution] [money] NULL
) ON [PRIMARY]
GO
